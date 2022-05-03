const mongoose = require("mongoose");

const productsSchema = new mongoose.Schema(
  {
    product_id: { type: Number, required: true },
    name: { type: String, required: true },
    cost: { type: Number, required: true },
    amount: { type: Number, required: true },
    publisher: { type: String, required: true },
    img: { type: String, required: false },
    description: { type: String, required: false },
    warranty: { type: Number, required: false },

    category: { type: String, required: true },
    subcategories: { type: Array, required: false },

    sale: { type: Boolean, required: false,  default: false},
    after_sale_price: { type: Number, required: false },
    rating: { type: Number, required: false },
    comments: { type: Array, required: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Product", productsSchema);
