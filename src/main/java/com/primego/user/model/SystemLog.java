package com.primego.user.model;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

public class SystemLog {
    private int id;
    private String level;
    private String message;
    private Timestamp createdAt;

    public SystemLog() {
    }

    public SystemLog(int id, String level, String message, Timestamp createdAt) {
        this.id = id;
        this.level = level;
        this.message = message;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // Helper for JSP to get formatted time string
    public String getTime() {
        if (createdAt == null)
            return "";
        return createdAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("hh:mm a", java.util.Locale.ENGLISH));
    }
}
