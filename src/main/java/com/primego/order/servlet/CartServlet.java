package com.primego.order.servlet;

import com.primego.order.dao.CartDAO;
import com.primego.order.model.Cart;
import com.primego.order.model.CartItem;
import com.primego.product.dao.ProductDAO;
import com.primego.product.model.ProductDTO;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/cart_action")
public class CartServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Initialize the cart in session. If the user is logged in, load from the database; otherwise create a new cart.
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            if (user != null) {
                cart = cartDAO.getCartByUserId(user.getId());
            } else {
                cart = new Cart();
            }
            session.setAttribute("cart", cart);
        }

        if ("add".equals(action)) {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null) {
                int productId = Integer.parseInt(productIdStr);
                ProductDTO product = productDAO.getProductById(productId);

                if (product != null) {
                    // Determine the current quantity of this product already in the cart.
                    int currentQty = 0;
                    for (CartItem item : cart.getItems()) {
                        if (item.getProduct().getProductId() == productId) {
                            currentQty = item.getQuantity();
                            break;
                        }
                    }

                    // Stock guard: only add if (current quantity + 1) does not exceed available stock.
                    if (currentQty + 1 <= product.getProductStockQuantity()) {
                        CartItem item = new CartItem(product, 1);
                        cart.addItem(item);

                        if (user != null) {
                            int cartId = cartDAO.getOrCreateCartId(user.getId());
                            cartDAO.addItemToCart(cartId, productId, 1);
                        }
                    } else {
                        // Optional: store a message in session so the UI can display an out-of-stock warning.
                        session.setAttribute("cartError", "Cannot add more items. Stock limit reached for " + product.getProductName());
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");

        } else if ("update".equals(action)) {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");

            if (productIdStr != null && quantityStr != null) {
                try {
                    int productId = Integer.parseInt(productIdStr);
                    int quantity = Integer.parseInt(quantityStr);

                    // Load stock information for validation.
                    ProductDTO product = productDAO.getProductById(productId);
                    int stock = (product != null) ? product.getProductStockQuantity() : 0;

                    if (quantity > 0) {
                        // If the requested quantity exceeds stock, cap it to the available stock.
                        if (quantity > stock) {
                            quantity = stock;
                            session.setAttribute("cartError", "Quantity adjusted to maximum stock for " + product.getProductName());
                        }

                        cart.updateQuantity(productId, quantity);
                        if (user != null) {
                            int cartId = cartDAO.getOrCreateCartId(user.getId());
                            cartDAO.updateItemQuantityPublic(cartId, productId, quantity);
                        }
                    }
                } catch (NumberFormatException e) {
                    // Ignore invalid numeric input.
                }
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");

        } else if ("remove".equals(action)) {
            // Remove a single product from the cart.
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null) {
                int productId = Integer.parseInt(productIdStr);
                cart.removeItem(productId);

                if (user != null) {
                    int cartId = cartDAO.getOrCreateCartId(user.getId());
                    cartDAO.removeItemFromCart(cartId, productId);
                }
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");

        } else if ("clear".equals(action)) {
            // Clear all items from the cart.
            cart.clear();
            if (user != null) {
                int cartId = cartDAO.getOrCreateCartId(user.getId());
                cartDAO.clearCart(cartId);
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");
        } else {
            // Default behavior: refresh the cart from the database for logged-in users.
            if (user != null) {
                cart = cartDAO.getCartByUserId(user.getId());
                session.setAttribute("cart", cart);
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");
        }
    }
}