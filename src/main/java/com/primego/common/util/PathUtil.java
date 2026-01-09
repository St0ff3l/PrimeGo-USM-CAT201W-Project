package com.primego.common.util;

import javax.servlet.ServletContext;
import java.io.File;

public class PathUtil {

    /**
     * 获取图片上传的目标路径
     * 策略：
     * 1. 优先检查环境变量 (适用于 Docker/服务器部署)
     * 2. 其次尝试自动寻找本地项目的 src 目录 (适用于 IDEA 本地开发，防止重启丢图)
     * 3. 最后回退到 Tomcat 运行目录 (保底方案)
     *
     * @param context ServletContext
     * @param subDir  子目录名称 (例如 "products", "rechargephotos", "withdrawphotos")
     * @return 绝对路径
     */
    public static String getUploadDir(ServletContext context, String subDir) {
        // -----------------------------------------------------------
        // 策略 1: 环境变量 (生产环境/Docker 推荐)
        // -----------------------------------------------------------
        String envPath = System.getenv("PRIMEGO_UPLOAD_DIR");
        if (envPath != null && !envPath.isEmpty()) {
            File dir = new File(envPath + File.separator + subDir);
            if (!dir.exists()) dir.mkdirs();
            return dir.getAbsolutePath();
        }

        // -----------------------------------------------------------
        // 策略 2: 本地开发自动定位 src 目录 (防止硬编码 /Users/zhangyifei...)
        // -----------------------------------------------------------
        
        // Debug: 打印当前运行目录，方便调试
        System.out.println("[PathUtil] user.dir: " + System.getProperty("user.dir"));

        // 2.1 优先尝试硬编码的已知项目路径 (解决 IDEA 运行路径不一致问题)
        String hardcodedPath = "/Users/zhangyifei/IdeaProjects/PrimeGo-USM-CAT201W-Project";
        File hardcodedDir = new File(hardcodedPath + File.separator + "src" + File.separator + "main" + File.separator + "webapp");
        if (hardcodedDir.exists()) {
            String localSourcePath = hardcodedDir.getAbsolutePath() + File.separator + "assets" + File.separator + "images" + File.separator + subDir;
            File dir = new File(localSourcePath);
            if (!dir.exists()) dir.mkdirs();
            System.out.println("[PathUtil] Found local source: " + localSourcePath);
            return localSourcePath;
        }

        // 2.2 尝试基于 user.dir 自动寻找
        // System.getProperty("user.dir") 在 IDEA 中运行时，通常是项目的根目录
        String projectRoot = System.getProperty("user.dir");

        // 检查这是一个标准的 Maven/Web 项目结构吗？
        File srcDir = new File(projectRoot + File.separator + "src" + File.separator + "main" + File.separator + "webapp");

        if (srcDir.exists()) {
            // 拼凑出 target 目录: src/main/webapp/assets/images/<subDir>
            String localSourcePath = srcDir.getAbsolutePath() + File.separator + "assets" + File.separator + "images" + File.separator + subDir;
            File dir = new File(localSourcePath);
            if (!dir.exists()) dir.mkdirs();
            System.out.println("[PathUtil] Found local source (auto): " + localSourcePath);
            return localSourcePath;
        }

        // -----------------------------------------------------------
        // 策略 3: 保底方案 (存到 Tomcat 临时运行目录)
        // -----------------------------------------------------------
        // 如果上面都没找到，就存到当前的运行目录里 (重启可能会丢失，但能保证程序不报错)
        String fallbackPath = context.getRealPath("/") + "assets" + File.separator + "images" + File.separator + subDir;
        File dir = new File(fallbackPath);
        if (!dir.exists()) dir.mkdirs();
        return fallbackPath;
    }

    /**
     * 默认方法，兼容旧代码，默认存到 products
     */
    public static String getUploadDir(ServletContext context) {
        return getUploadDir(context, "products");
    }
}
