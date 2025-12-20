package com.primego.common.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class PasswordUtil {

    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        String newHash = hashPassword(plainPassword);
        System.out.println("[DEBUG] Password Check:");
        System.out.println("  Input Plain: " + plainPassword);
        System.out.println("  Computed Hash: " + newHash);
        System.out.println("  DB Stored Hash: " + hashedPassword);
        System.out.println("  Match: " + newHash.equals(hashedPassword));
        return newHash.equals(hashedPassword);
    }
}
