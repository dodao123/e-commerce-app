import '../models/product_model.dart';

/// Load image mock data from pngwing, cleanpng, stickpng, pngimg, vecteezy.

/// Local data source providing mock product data for development.
class ProductLocalDatasource {
  /// Returns a list of mock products matching the design mockup.
  static List<ProductModel> getMockProducts() {
    return const [
      ProductModel(
        id: '1',
        name: 'Headphone X1',
        nameVi: 'Tai Nghe X1',
        price: 600,
        imageUrl: 'assets/images/HeadphoneX1.webp',
        imageDetail: [
          'https://static.vecteezy.com/system/resources/previews/054/633/641/non_2x/headphones-on-a-transparent-background-png.png',
          'https://static.vecteezy.com/system/resources/previews/050/760/263/non_2x/white-over-ear-headphones-with-silver-accents-png.png',
          'https://static.vecteezy.com/system/resources/previews/024/558/820/large_2x/black-wireless-headphones-isolated-on-transparent-background-ai-generated-png.png',
        ],
        category: 'New Product',
        description: 'With warm & smooth sound, exceptional battery '
            'life and comfortable design, entry-level wireless '
            'headphones don\'t get better than this.',
        descriptionVi: 'Với âm thanh ấm áp, mượt mà, thời lượng pin '
            'vượt trội và thiết kế thoải mái, tai nghe không dây '
            'phân khúc phổ thông không thể tốt hơn thế này.',
        rating: 5.0,
        reviewCount: 24,
        isNew: true,
      ),
      ProductModel(
        id: '2',
        name: 'Controller B25',
        nameVi: 'Tay Cầm B25',
        price: 280,
        imageUrl: 'assets/images/Controller_b25.webp',
        imageDetail: [
          'https://pngimg.com/uploads/joystick/joystick_PNG11256.png',
          'https://pngimg.com/uploads/joystick/joystick_PNG11255.png',
          'https://pngimg.com/uploads/joystick/small/joystick_PNG11270.png',
        ],
        category: 'Popular',
        description: 'Ergonomic game controller with precise analog '
            'sticks and responsive buttons for ultimate gaming.',
        descriptionVi: 'Tay cầm chơi game công thái học với cần analog '
            'chính xác và nút bấm nhạy cho trải nghiệm tối ưu.',
      ),
      ProductModel(
        id: '3',
        name: 'Headphone X11',
        nameVi: 'Tai Nghe X11',
        price: 600,
        imageUrl: 'assets/images/HeadphoneX11.webp',
        imageDetail: [
          'https://static.vecteezy.com/system/resources/previews/020/032/758/large_2x/headphones-isolated-on-transparent-background-free-png.png',
          'https://static.vecteezy.com/system/resources/previews/020/032/715/non_2x/headphones-isolated-on-transparent-background-free-png.png',
          'https://static.vecteezy.com/system/resources/previews/024/558/820/large_2x/black-wireless-headphones-isolated-on-transparent-background-ai-generated-png.png',
        ],
        category: 'Recommended',
        description: 'Premium over-ear headphones with active noise '
            'cancellation and Hi-Res audio certification.',
        descriptionVi: 'Tai nghe chụp tai cao cấp với chống ồn chủ động '
            'và chứng nhận âm thanh Hi-Res.',
      ),
      ProductModel(
        id: '4',
        name: 'Wireless Mouse Z123',
        nameVi: 'Chuột Không Dây Z123',
        price: 280,
        imageUrl: 'assets/images/mouse.webp',
        imageDetail: [
          'https://static.vecteezy.com/system/resources/previews/054/633/641/non_2x/headphones-on-a-transparent-background-png.png',
          'https://static.vecteezy.com/system/resources/previews/050/760/263/non_2x/white-over-ear-headphones-with-silver-accents-png.png',
          'https://static.vecteezy.com/system/resources/previews/024/558/820/large_2x/black-wireless-headphones-isolated-on-transparent-background-ai-generated-png.png',
        ],
        category: 'Popular',
        description: 'Ergonomic wireless mouse with precision tracking.',
        descriptionVi: 'Chuột không dây công thái học với cảm biến chính xác.',
      ),
    ];
  }
}
