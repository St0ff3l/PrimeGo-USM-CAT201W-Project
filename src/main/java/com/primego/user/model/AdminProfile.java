package com.primego.user.model;

public class AdminProfile {
    private int userId;
    private String department;
    private int level;

    public AdminProfile() {}

    public AdminProfile(int userId, String department, int level) {
        this.userId = userId;
        this.department = department;
        this.level = level;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }
}
