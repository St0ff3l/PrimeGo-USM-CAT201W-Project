package com.primego.common.listener;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import java.util.concurrent.atomic.AtomicInteger;

@WebListener
public class ActiveSessionListener implements HttpSessionListener {
    private static final AtomicInteger activeSessions = new AtomicInteger(0);

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        activeSessions.incrementAndGet();
        // Record persistent visit
        new com.primego.user.dao.VisitDAO().incrementVisit();
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        // Ensure count doesn't go below zero
        if (activeSessions.get() > 0) {
            activeSessions.decrementAndGet();
        }
    }

    public static int getActiveSessionsCount() {
        return activeSessions.get();
    }
}
