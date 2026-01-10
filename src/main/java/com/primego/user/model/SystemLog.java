package com.primego.user.model;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

/**
 * Represents a system log entry.
 * Used for tracking administrative actions and system events.
 */
public class SystemLog {
    private int id;
    private String level;
    private String message;
    private Timestamp createdAt;

    public SystemLog() {
    }

    /**
     * Constructs a new SystemLog.
     *
     * @param id        The log ID.
     * @param level     The severity level (e.g., INFO, ERROR).
     * @param message   The log message.
     * @param createdAt The timestamp when the log was created.
     */
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

    /**
     * Formats the timestamp into a readable time string (hh:mm a).
     * Useful for JSP display.
     *
     * @return The formatted time string, or empty if null.
     */
    public String getTime() {
        if (createdAt == null)
            return "";
        return createdAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("hh:mm a", java.util.Locale.ENGLISH));
    }
}
