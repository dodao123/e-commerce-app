"""Background removal microservice using rembg (U2Net).

Receives image via POST /remove-bg, returns PNG with
transparent background. Used by Go backend during
product image upload.
"""

import io
from flask import Flask, request, send_file, jsonify
from rembg import remove
from PIL import Image

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint for service monitoring."""
    return jsonify({"status": "ok"})


@app.route("/remove-bg", methods=["POST"])
def remove_background():
    """Remove background from uploaded image.

    Accepts multipart/form-data with 'image' file field.
    Returns PNG image with transparent background.
    """
    if "image" not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    file = request.files["image"]
    if file.filename == "":
        return jsonify({"error": "Empty filename"}), 400

    try:
        input_image = Image.open(file.stream)
        output_image = remove(input_image)

        # Convert to PNG bytes with alpha channel
        buffer = io.BytesIO()
        output_image.save(buffer, format="PNG")
        buffer.seek(0)

        return send_file(
            buffer,
            mimetype="image/png",
            as_attachment=True,
            download_name="processed.png",
        )
    except Exception as error:
        return jsonify({"error": str(error)}), 500


if __name__ == "__main__":
    print("Background Removal Service starting on :5050")
    app.run(host="0.0.0.0", port=5050, debug=False)
