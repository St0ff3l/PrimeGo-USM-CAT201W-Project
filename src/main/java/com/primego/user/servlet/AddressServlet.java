package com.primego.user.servlet;

import com.primego.user.dao.AddressDAO;
import com.primego.user.model.User;
import com.primego.user.model.UserAddress;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet handling user address management (CRUD).
 * Supports adding, updating, deleting, and setting default addresses.
 */
@WebServlet("/user/address")
public class AddressServlet extends HttpServlet {
    private AddressDAO addressDAO = new AddressDAO();

    /**
     * Handles GET requests to list addresses.
     * Often used via AJAX or internal includes.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        User user = (User) session.getAttribute("user");

        String action = req.getParameter("action");
        if ("list".equals(action)) {
            // Gson not available, skip JSON response for now or implement manual JSON if
            // needed
            // For now, we rely on JSP rendering via ProfileServlet
            resp.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED, "JSON list not supported without Gson");
        } else {
            // Default could be redirecting to list page or something, but we mainly use
            // JSON via AJAX or JSP include
            List<UserAddress> addresses = addressDAO.getAddressesByUserId(user.getId());
            req.setAttribute("addresses", addresses);
        }
    }

    /**
     * Handles POST requests for address actions: add, update, delete, setDefault.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");

        String action = req.getParameter("action");
        String message = "";
        String messageType = "error";

        if ("add".equals(action)) {
            UserAddress addr = new UserAddress();
            addr.setUserId(user.getId());
            addr.setRecipientName(req.getParameter("recipientName"));
            addr.setPhone(req.getParameter("phone"));
            addr.setProvince(req.getParameter("province"));
            addr.setCity(req.getParameter("city"));
            addr.setDistrict(req.getParameter("district"));
            addr.setDetail(req.getParameter("detail"));
            addr.setDefaultAddress("true".equals(req.getParameter("isDefault")));

            if (addressDAO.addAddress(addr)) {
                message = "Address added successfully!";
                messageType = "success";
            } else {
                message = "Failed to add address.";
            }

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(req.getParameter("addressId"));
            UserAddress addr = addressDAO.getAddressById(id);
            if (addr != null && addr.getUserId() == user.getId()) {
                addr.setRecipientName(req.getParameter("recipientName"));
                addr.setPhone(req.getParameter("phone"));
                addr.setProvince(req.getParameter("province"));
                addr.setCity(req.getParameter("city"));
                addr.setDistrict(req.getParameter("district"));
                addr.setDetail(req.getParameter("detail"));
                addr.setDefaultAddress("true".equals(req.getParameter("isDefault")));

                if (addressDAO.updateAddress(addr)) {
                    message = "Address updated successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to update address.";
                }
            } else {
                message = "Address not found or unauthorized.";
            }

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("addressId"));
            UserAddress addr = addressDAO.getAddressById(id);
            if (addr != null && addr.getUserId() == user.getId()) {
                if (addressDAO.deleteAddress(id)) {
                    message = "Address deleted successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to delete address.";
                }
            }

        } else if ("setDefault".equals(action)) {
            int id = Integer.parseInt(req.getParameter("addressId"));
            if (addressDAO.setDefaultAddress(user.getId(), id)) {
                message = "Default address set successfully!";
                messageType = "success";
            } else {
                message = "Failed to set default address.";
            }
        }

        // Redirect back to profile address tab
        req.getSession().setAttribute("message", message);
        req.getSession().setAttribute("messageType", messageType);
        // We use a query param 'tab=addresses' to help frontend switch tab
        // automatically
        resp.sendRedirect(req.getContextPath() + "/profile?tab=addresses");
    }
}
