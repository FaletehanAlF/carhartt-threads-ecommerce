import '../models/product.dart';

/// Katalog lokal — dipakai sebagai fallback offline
/// sekaligus sumber utama agar tampilan konsisten.
const List<String> productCategories = [
  'All',
  'T-Shirt',
  'Hoodie',
  'Jacket',
  'Pants',
  'Bag',
  'Accessories',
];

final List<Product> products = [
  Product(
    id: 1,
    name: 'K87 T-Shirt',
    category: 'T-Shirt',
    price: 599000,
    image:
        'https://i.pinimg.com/736x/65/ca/e1/65cae1f82301cef3f3dceb61993dd916.jpg',
    description:
        'Kaos pocket klasik Carhartt dari katun heavyweight. Potongan loose, jahitan kuat, cocok untuk kerja maupun harian.',
  ),
  Product(
    id: 2,
    name: 'Midweight Hoodie',
    category: 'Hoodie',
    price: 899000,
    image: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800',
    description:
        'Hoodie midweight dengan fleece lembut di dalam. Hangat, tahan lama, dengan kantong kanguru dan drawcord adjustable.',
  ),
  Product(
    id: 3,
    name: 'Detroit Jacket',
    category: 'Jacket',
    price: 1499000,
    image: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800',
    description:
        'Ikon workwear sejak 1950-an. Blanket-lined, resleting depan kokoh, dan saku corduroy. Dibuat untuk cuaca dingin.',
  ),
  Product(
    id: 4,
    name: 'Double Knee Pants',
    category: 'Pants',
    price: 1099000,
    image:
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800',
    description:
        'Celana kerja double-front dengan lutut ganda. Ruang lutut bisa disisipi knee pad. Material duck canvas yang sangat kuat.',
  ),
  Product(
    id: 5,
    name: 'Essential Bag',
    category: 'Bag',
    price: 699000,
    image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800',
    description:
        'Tas selempang kanvas tahan air dengan kompartemen laptop. Tali adjustable dan saku cepat di bagian depan.',
  ),
  Product(
    id: 6,
    name: 'Canvas Cap',
    category: 'Accessories',
    price: 499000,
    image: 'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=800',
    description:
        'Topi kanvas dengan strap kulit adjustable. Bordir logo Carhartt, nyaman dipakai seharian.',
  ),
  Product(
    id: 7,
    name: 'Heavyweight T-Shirt',
    category: 'T-Shirt',
    price: 649000,
    image: 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=800',
    description:
        'Kaos heavyweight 6.75 oz dengan rib-knit collar yang tidak mudah melar. Pre-shrunk dan garment-dyed.',
  ),
  Product(
    id: 8,
    name: 'Chase Sweatshirt',
    category: 'Hoodie',
    price: 799000,
    image: 'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=800',
    description:
        'Crewneck Chase dengan bordir logo dada. Fleece brushed yang lembut dan hangat untuk layering.',
  ),
  Product(
    id: 9,
    name: 'Active Jacket',
    category: 'Jacket',
    price: 1399000,
    image: 'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=800',
    description:
        'Active Jac dengan quilted lining. Ringan tapi hangat, wind-resistant, dan punya tiga saku luar.',
  ),
  Product(
    id: 10,
    name: 'Cargo Pants',
    category: 'Pants',
    price: 1199000,
    image:
        'https://images.unsplash.com/photo-1517445312882-7f2a1e6e9d1f?w=800',
    description:
        'Celana cargo ripstop dengan 6 saku fungsional. Potongan relaxed dan reinforced di area lutut.',
  ),
  Product(
    id: 11,
    name: 'Workwear Overshirt',
    category: 'Jacket',
    price: 1299000,
    image: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=800',
    description:
        'Overshirt flannel brushed dengan kancing kokoh. Bisa dipakai sebagai kemeja atau jaket ringan.',
  ),
  Product(
    id: 12,
    name: 'Pocket T-Shirt',
    category: 'T-Shirt',
    price: 549000,
    image: 'https://images.unsplash.com/photo-1583743814966-8936f37f4b7d?w=800',
    description:
        'Kaos saku dada dari katun jersey. Fit regular yang nyaman untuk aktivitas harian.',
  ),
  Product(
    id: 13,
    name: 'Logo Sweatshirt',
    category: 'Hoodie',
    price: 849000,
    image:
        'https://images.unsplash.com/photo-1578681994506-b0602bf1aba9?w=800',
    description:
        'Sweatshirt grafis logo besar di punggung. Material fleece tebal dengan ribbed cuff.',
  ),
  Product(
    id: 14,
    name: 'Workwear Shorts',
    category: 'Pants',
    price: 749000,
    image: 'https://images.unsplash.com/photo-1565084888279-aca607ecce0c?w=800',
    description:
        'Celana pendek kanvas dengan inseam nyaman. Saku samping dalam dan loop sabuk yang kuat.',
  ),
  Product(
    id: 15,
    name: 'Nylon Backpack',
    category: 'Bag',
    price: 999000,
    image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800',
    description:
        'Backpack nylon 25L tahan air dengan padded laptop sleeve 15 inci dan panel punggung berventilasi.',
  ),
  Product(
    id: 16,
    name: 'Acrylic Watch Hat',
    category: 'Accessories',
    price: 399000,
    image: 'https://images.unsplash.com/photo-1575428652377-a2d80e2277fc?w=800',
    description:
        'Kupluk rib-knit ikonik Carhartt. Hangat, stretch, dan tersedia dalam banyak warna.',
  ),
  Product(
    id: 17,
    name: 'Canvas Work Jacket',
    category: 'Jacket',
    price: 1599000,
    image:
        'https://images.unsplash.com/photo-1520975958225-6b3c7c2d4f2e?w=800',
    description:
        'Jaket kanvas washed-duck dengan corduroy collar. Blanket lining untuk kehangatan ekstra.',
  ),
  Product(
    id: 18,
    name: 'Relaxed Fit Jeans',
    category: 'Pants',
    price: 1249000,
    image: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800',
    description:
        'Jeans relaxed-fit dari denim stretch. Kuat untuk kerja, nyaman untuk harian.',
  ),
  Product(
    id: 19,
    name: 'Utility Vest',
    category: 'Jacket',
    price: 1099000,
    image: 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=800',
    description:
        'Vest utilitas dengan banyak saku dan resleting dua arah. Layering ideal untuk cuaca transisi.',
  ),
  Product(
    id: 20,
    name: 'Classic Work Shirt',
    category: 'T-Shirt',
    price: 899000,
    image: 'https://images.unsplash.com/photo-1603252110481-7ba873bf42ab?w=800',
    description:
        'Kemeja kerja twill dengan dua saku dada berkancing. Potongan middleweight yang rapi.',
  ),
];
