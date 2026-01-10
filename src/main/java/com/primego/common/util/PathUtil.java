package com.primego.common.util;

import javax.servlet.ServletContext;
import java.io.File;

public class PathUtil {

    /**
     * Resolves the target directory for uploaded images.
     *
     * Resolution strategy:
     * 1) Prefer an environment variable (recommended for Docker/server deployments).
     * 2) Otherwise, try to locate the local project source directory (useful for IDE local development so files
     *    persist across restarts).
     * 3) Finally, fall back to the servlet container's runtime directory.
     *
     * @param context ServletContext
     * @param subDir  Subdirectory name (for example: "products", "rechargephotos", "withdrawphotos")
     * @return Absolute path to the upload directory
     */
    public static String getUploadDir(ServletContext context, String subDir) {
        // -----------------------------------------------------------
        // Strategy 1: environment variable (recommended for production/Docker)
        // -----------------------------------------------------------
        String envPath = System.getenv("PRIMEGO_UPLOAD_DIR");
        if (envPath != null && !envPath.isEmpty()) {
            File dir = new File(envPath + File.separator + subDir);
            if (!dir.exists()) dir.mkdirs();
            return dir.getAbsolutePath();
        }

        // -----------------------------------------------------------
        // Strategy 2: local development - try to locate src/main/webapp (avoid hardcoding an absolute path)
        // -----------------------------------------------------------

        // Debug: print the current working directory to help diagnose path resolution issues
        System.out.println("[PathUtil] user.dir: " + System.getProperty("user.dir"));

        // 2.1 Try a known project path first (handles cases where the IDE working directory differs)
        String hardcodedPath = "/Users/zhangyifei/IdeaProjects/PrimeGo-USM-CAT201W-Project";
        File hardcodedDir = new File(hardcodedPath + File.separator + "src" + File.separator + "main" + File.separator + "webapp");
        if (hardcodedDir.exists()) {
            String localSourcePath = hardcodedDir.getAbsolutePath() + File.separator + "assets" + File.separator + "images" + File.separator + subDir;
            File dir = new File(localSourcePath);
            if (!dir.exists()) dir.mkdirs();
            System.out.println("[PathUtil] Found local source: " + localSourcePath);
            return localSourcePath;
        }

        // 2.2 Try to locate the project root based on user.dir
        // In IDE runs, System.getProperty("user.dir") is often the project root directory
        String projectRoot = System.getProperty("user.dir");

        // Check whether this looks like a standard Maven/Web project structure
        File srcDir = new File(projectRoot + File.separator + "src" + File.separator + "main" + File.separator + "webapp");

        if (srcDir.exists()) {
            // Resolve to: src/main/webapp/assets/images/<subDir>
            String localSourcePath = srcDir.getAbsolutePath() + File.separator + "assets" + File.separator + "images" + File.separator + subDir;
            File dir = new File(localSourcePath);
            if (!dir.exists()) dir.mkdirs();
            System.out.println("[PathUtil] Found local source (auto): " + localSourcePath);
            return localSourcePath;
        }

        // -----------------------------------------------------------
        // Strategy 3: fallback (store under the servlet container's runtime directory)
        // -----------------------------------------------------------
        // If none of the above paths are available, store under the current deployed webapp directory.
        // Note: files stored here may be lost on restart/redeploy, but this keeps the application functional.
        String fallbackPath = context.getRealPath("/") + "assets" + File.separator + "images" + File.separator + subDir;
        File dir = new File(fallbackPath);
        if (!dir.exists()) dir.mkdirs();
        return fallbackPath;
    }

    /**
     * Backward-compatible overload. Uses "products" as the default subdirectory.
     */
    public static String getUploadDir(ServletContext context) {
        return getUploadDir(context, "products");
    }
}
