package handler

import (
	"bytes"
	"context"
	"delivery-app/backend/internal/model"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
)

func (h *ChatHandler) triggerAIAssistant(ctx context.Context, customerMsg *model.ChatMessage, shop *model.Shop) {
	log.Printf("[AI Assistant] Triggered for message: '%s', shop: '%s'", customerMsg.Content, shop.ShopName)
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		log.Printf("[AI Assistant] Error: GEMINI_API_KEY env var is empty")
		return
	}

	// Retrieve products context from this shop only (max 50)
	products, err := h.searchService.ListProductsByShopPublic(ctx, shop.ID, "", 50)
	if err != nil {
		log.Printf("[AI Assistant] ListProductsByShopPublic error: %v", err)
	}

	var catalogBuilder strings.Builder
	if err == nil {
		for i, p := range products {
			optionsStr := ""
			if len(p.Options) > 0 {
				var opts []string
				for _, optGroup := range p.Options {
					opts = append(opts, fmt.Sprintf("%s (%s)", optGroup.Name, strings.Join(optGroup.Values, ", ")))
				}
				optionsStr = fmt.Sprintf(", Options: %s", strings.Join(opts, " | "))
			}
			imgStr := ""
			if len(p.Images) > 0 {
				imgStr = fmt.Sprintf(", Image URL: %s", p.Images[0])
			}
			catalogBuilder.WriteString(fmt.Sprintf(
				"%d. Name: %s, Price: %.0f VND, Stock: %d, Condition: %s, Description: %s%s%s\n",
				i+1, p.Name, p.Price, p.Stock, p.Condition, p.Description, optionsStr, imgStr,
			))
		}
	}

	catalogContext := catalogBuilder.String()
	if catalogContext == "" {
		catalogContext = "No products currently in stock."
	}
	log.Printf("[AI Assistant] Retrieved products context:\n%s", catalogContext)

	prompt := fmt.Sprintf(
		"You are a warm, highly persuasive, and energetic professional salesperson at '%s'. You must NEVER state that you are Gemini, Google, OpenAI, or a large language model. If asked who or what you are, state ONLY that you are the AI Assistant of '%s'.\n\n"+
			"Customer asked: '%s'\n\n"+
			"Shop stock (catalog): \n%s\n\n"+
			"Instructions for response:\n"+
			"1. Respond nicely in the customer's language.\n"+
			"2. DO NOT use any markdown characters like double asterisks '**' or single asterisks '*' for bold/italic. Instead, write in clean, plain Vietnamese, using capitalization or clean spacing for emphasis (e.g., write 'GIA:' or 'TINH TRANG:' instead of '**Giá:**').\n"+
			"3. DO NOT just dryly list the technical specifications. Act like a real friendly sales advisor. Introduce the key highlights and benefits of the product to make it sound appealing, explain why the customer should buy it, and guide them warmly to place an order.\n"+
			"4. DO NOT invent products. Only talk about products present in the catalog context above. If the customer asks for something not in the catalog, state politely that the shop does not have it.\n"+
			"5. ONLY output the image marker [IMAGE_URL: <image_url_from_catalog>] if the customer explicitly asks to see a photo, image, picture, or look at the product (e.g. 'gửi ảnh', 'cho xem hình', 'show photo', 'gửi hình sản phẩm'). If the customer only asks about pricing, description, availability, or general questions (e.g. 'vậy còn web cam thì sao', 'có webcam không', 'giá bao nhiêu'), you MUST NOT output the [IMAGE_URL: ...] marker. Just describe it in text.\n"+
			"6. Keep it concise, friendly, and structured. Maximum 150 words.",
		shop.ShopName, shop.ShopName, customerMsg.Content, catalogContext,
	)

	aiReply := h.callGeminiAPI(ctx, apiKey, prompt)
	if aiReply == "" {
		log.Printf("[AI Assistant] Gemini API returned empty reply")
		return
	}
	log.Printf("[AI Assistant] Gemini reply: '%s'", aiReply)

	// Clean up markdown formatting syntax (** and *) to ensure clean rendering on mobile
	aiReply = strings.ReplaceAll(aiReply, "**", "")
	aiReply = strings.ReplaceAll(aiReply, "*", "-")

	// Parse image URL from reply if present
	var imageUrl string
	if idx := strings.Index(aiReply, "[IMAGE_URL:"); idx != -1 {
		endIdx := strings.Index(aiReply[idx:], "]")
		if endIdx != -1 {
			imageUrl = strings.TrimSpace(aiReply[idx+len("[IMAGE_URL:") : idx+endIdx])
			aiReply = strings.TrimSpace(aiReply[:idx] + aiReply[idx+endIdx+1:])
		}
	}

	// Save AI assistant reply text message
	aiMsg, err := h.chatService.SendMessage(ctx, shop.SellerID, "ai_assistant", customerMsg.RoomID, aiReply, "text")
	if err != nil {
		log.Printf("[AI Assistant] Error saving AI text message: %v", err)
		return
	}
	log.Printf("[AI Assistant] AI text message saved. Routing message...")
	h.routeMessage(ctx, aiMsg)

	// Save AI assistant reply image message if present
	if imageUrl != "" {
		aiImgMsg, err := h.chatService.SendMessage(ctx, shop.SellerID, "ai_assistant", customerMsg.RoomID, imageUrl, "image")
		if err != nil {
			log.Printf("[AI Assistant] Error saving AI image message: %v", err)
			return
		}
		log.Printf("[AI Assistant] AI image message saved. Routing message...")
		h.routeMessage(ctx, aiImgMsg)
	}
}

func (h *ChatHandler) callGeminiAPI(ctx context.Context, apiKey, prompt string) string {
	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=%s", apiKey)
	reqBody := map[string]interface{}{
		"contents": []map[string]interface{}{
			{
				"parts": []map[string]string{
					{"text": prompt},
				},
			},
		},
	}
	jsonBytes, _ := json.Marshal(reqBody)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewBuffer(jsonBytes))
	if err != nil {
		log.Printf("[AI Gemini API] NewRequest error: %v", err)
		return ""
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Printf("[AI Gemini API] Http request error: %v", err)
		return ""
	}
	defer resp.Body.Close()

	respBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		log.Printf("[AI Gemini API] Error response status: %d, body: %s", resp.StatusCode, string(respBytes))
		return ""
	}

	var result struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}
	if err := json.Unmarshal(respBytes, &result); err != nil {
		log.Printf("[AI Gemini API] Json unmarshal error: %v", err)
		return ""
	}
	if len(result.Candidates) == 0 || len(result.Candidates[0].Content.Parts) == 0 {
		log.Printf("[AI Gemini API] Empty candidates in result: %s", string(respBytes))
		return ""
	}
	return strings.TrimSpace(result.Candidates[0].Content.Parts[0].Text)
}
