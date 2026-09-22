// 20 produk demo Carhartt — 5 T-Shirt, 5 Hoodie, 5 Jacket, 5 Pants
// Field wajib: id, image, name, category, rating, price, description, sizes

const products = [
  // T-Shirt (5)
  {
    id: 1,
    image: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800",
    name: "K87 Pocket T-Shirt",
    category: "T-Shirt",
    rating: 4.8,
    price: 299000,
    description: "Heavyweight cotton T-shirt dengan desain workwear klasik dan chest pocket yang fungsional.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 2,
    image: "https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=800",
    name: "Heavyweight Workwear T-Shirt",
    category: "T-Shirt",
    rating: 4.7,
    price: 349000,
    description: "Kaos heavyweight 6.75 oz dengan jahitan kuat dan bahan katun premium yang nyaman seharian.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 3,
    image: "https://images.unsplash.com/photo-1583743814966-8936f37f4b7d?w=800",
    name: "Loose Fit Graphic T-Shirt",
    category: "T-Shirt",
    rating: 4.6,
    price: 329000,
    description: "Kaos loose fit dengan grafis Carhartt yang ikonik dan potongan relaxed untuk gaya casual.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 4,
    image: "https://images.unsplash.com/photo-1603252110481-7ba873bf42ab?w=800",
    name: "Original Logo T-Shirt",
    category: "T-Shirt",
    rating: 4.9,
    price: 279000,
    description: "Kaos klasik dengan logo Carhartt bordir di dada dan bahan lembut yang breathable.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 5,
    image: "https://i.pinimg.com/736x/65/ca/e1/65cae1f82301cef3f3dceb61993dd916.jpg",
    name: "Pocket Work T-Shirt",
    category: "T-Shirt",
    rating: 4.8,
    price: 319000,
    description: "T-shirt workwear dengan saku dada dan konstruksi jahitan triple-stitched yang tahan lama.",
    sizes: ["S", "M", "L", "XL"]
  },

  // Hoodie (5)
  {
    id: 6,
    image: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800",
    name: "Midweight Logo Hoodie",
    category: "Hoodie",
    rating: 4.9,
    price: 699000,
    description: "Hoodie berbahan midweight dengan potongan nyaman untuk penggunaan sehari-hari.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 7,
    image: "https://images.unsplash.com/photo-1578681994506-b0602bf1aba9?w=800",
    name: "Heavyweight Pullover Hoodie",
    category: "Hoodie",
    rating: 4.8,
    price: 749000,
    description: "Pullover hoodie heavyweight dengan fleece hangat dan kantong kanguru yang luas.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 8,
    image: "https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=800",
    name: "Chase Logo Hoodie",
    category: "Hoodie",
    rating: 4.7,
    price: 659000,
    description: "Hoodie Chase dengan logo bordir di dada dan bahan lembut yang nyaman dipakai.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 9,
    image: "https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=800",
    name: "Relaxed Fit Hoodie",
    category: "Hoodie",
    rating: 4.8,
    price: 729000,
    description: "Hoodie relaxed fit dengan drawcord adjustable dan rib-knit cuff yang tidak mudah melar.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 10,
    image: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800",
    name: "Workwear Script Hoodie",
    category: "Hoodie",
    rating: 4.9,
    price: 699000,
    description: "Hoodie dengan script logo di depan dan konstruksi jahitan yang kuat untuk daya tahan ekstra.",
    sizes: ["S", "M", "L", "XL"]
  },

  // Jacket (5)
  {
    id: 11,
    image: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800",
    name: "Detroit Style Jacket",
    category: "Jacket",
    rating: 4.8,
    price: 1299000,
    description: "Jacket bergaya workwear dengan desain praktis dan cocok untuk aktivitas outdoor maupun casual.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 12,
    image: "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=800",
    name: "Active Workwear Jacket",
    category: "Jacket",
    rating: 4.7,
    price: 1199000,
    description: "Jacket ringan dengan quilted lining yang hangat dan tahan angin untuk cuaca dingin.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 13,
    image: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800",
    name: "Loose Fit Workwear Jacket",
    category: "Jacket",
    rating: 4.8,
    price: 1399000,
    description: "Work jacket loose fit dengan saku utilitas dan material duck canvas yang sangat kuat.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 14,
    image: "https://images.unsplash.com/photo-1520975958225-6b3c7c2d4f2e?w=800",
    name: "Michigan Coat Jacket",
    category: "Jacket",
    rating: 4.9,
    price: 1499000,
    description: "Coat jacket blanket-lined dengan kerah corduroy dan resleting kokoh untuk kehangatan maksimal.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 15,
    image: "https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=800",
    name: "WIP Work Jacket",
    category: "Jacket",
    rating: 4.7,
    price: 1099000,
    description: "Jacket work-in-progress dengan potongan modern dan bahan ringan yang nyaman untuk layering.",
    sizes: ["S", "M", "L", "XL"]
  },

  // Pants (5)
  {
    id: 16,
    image: "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800",
    name: "Rugged Work Pants",
    category: "Pants",
    rating: 4.7,
    price: 649000,
    description: "Work pants dengan material kuat dan potongan yang nyaman untuk aktivitas sehari-hari.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 17,
    image: "https://images.unsplash.com/photo-1517445312882-7f2a1e6e9d1f?w=800",
    name: "Loose Fit Cargo Pants",
    category: "Pants",
    rating: 4.8,
    price: 749000,
    description: "Cargo pants loose fit dengan 6 saku fungsional dan bahan ripstop yang tahan sobek.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 18,
    image: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=800",
    name: "Double Knee Work Pants",
    category: "Pants",
    rating: 4.9,
    price: 899000,
    description: "Celana double-front dengan lutut ganda dan ruang untuk knee pad, sangat kuat untuk kerja berat.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 19,
    image: "https://images.unsplash.com/photo-1565084888279-aca607ecce0c?w=800",
    name: "Relaxed Fit Jeans Pants",
    category: "Pants",
    rating: 4.6,
    price: 799000,
    description: "Jeans relaxed fit dengan denim stretch yang nyaman dan tahan lama untuk pemakaian harian.",
    sizes: ["S", "M", "L", "XL"]
  },
  {
    id: 20,
    image: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800",
    name: "Aviation Cargo Pants",
    category: "Pants",
    rating: 4.7,
    price: 849000,
    description: "Aviation pants dengan potongan tapered dan saku cargo yang praktis untuk gaya urban workwear.",
    sizes: ["S", "M", "L", "XL"]
  }
];

module.exports = products;
