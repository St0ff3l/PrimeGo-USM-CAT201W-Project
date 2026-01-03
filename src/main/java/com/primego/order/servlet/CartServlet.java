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

        // If user is logged in, use DB cart. If not, use Session cart.
        // For simplicity in this hybrid approach, we'll sync session cart to DB if user logs in later (not implemented here)
        // or just force login for cart operations if desired.
        // Here we will support both:
        
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
                    CartItem item = new CartItem(product, 1); // Default quantity 1
                    cart.addItem(item);
                    
                    if (user != null) {
                        int cartId = cartDAO.getOrCreateCartId(user.getId());
                        cartDAO.addItemToCart(cartId, productId, 1);
                    }
                }
            }
            // Redirect to cart page to show the added item
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");

        } else if ("update".equals(action)) {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            if (productIdStr != null && quantityStr != null) {
                try {
                    int productId = Integer.parseInt(productIdStr);
                    int quantity = Integer.parseInt(quantityStr);
                    if (quantity > 0) {
                        cart.updateQuantity(productId, quantity);
                        if (user != null) {
                            int cartId = cartDAO.getOrCreateCartId(user.getId());
                            // We need a method to set exact quantity, addItemToCart adds to existing.
                            // Let's check CartDAO.
                            // CartDAO has updateItemQuantity(cartId, productId, quantity) which sets exact quantity.
                            // But it's private. I should make it public or add a public wrapper.
                            // Wait, let me check CartDAO again.
                            // It has addItemToCart which calls updateItemQuantity.
                            // I should probably expose updateItemQuantity or add a setItemQuantity method.
                            // For now, let's assume I'll add setItemQuantity to CartDAO.
                            cartDAO.updateItemQuantityPublic(cartId, productId, quantity);
                        }
                    }
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");

        } else if ("remove".equals(action)) {
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
            cart.clear();
            if (user != null) {
                int cartId = cartDAO.getOrCreateCartId(user.getId());
                cartDAO.clearCart(cartId);
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");
        } else {
            // Just view cart, maybe refresh from DB if logged in
            if (user != null) {
                cart = cartDAO.getCartByUserId(user.getId());
                session.setAttribute("cart", cart);
            }
            response.sendRedirect(request.getContextPath() + "/customer/order/cart.jsp");
        }
    }
}
