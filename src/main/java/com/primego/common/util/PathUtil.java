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
     */
    public static String getUploadDir(ServletContext context) {
        // -----------------------------------------------------------
        // 策略 1: 环境变量 (生产环境/Docker 推荐)
        // -----------------------------------------------------------
        String envPath = System.getenv("PRIMEGO_UPLOAD_DIR");
        if (envPath != null && !envPath.isEmpty()) {
            File dir = new File(envPath);
            if (!dir.exists()) dir.mkdirs();
            return envPath; // 直接返回配置的路径
        }

        // -----------------------------------------------------------
        // 策略 2: 本地开发自动定位 src 目录 (防止硬编码 /Users/zhangyifei...)
        // -----------------------------------------------------------
        // System.getProperty("user.dir") 在 IDEA 中运行时，通常是项目的根目录
        String projectRoot = System.getProperty("user.dir");

        // 检查这是一个标准的 Maven/Web 项目结构吗？
        File srcDir = new File(projectRoot + File.separator + "src" + File.separator + "main" + File.separator + "webapp");

        if (srcDir.exists()) {
            // 拼凑出 target 目录: src/main/webapp/assets/images/products
            String localSourcePath = srcDir.getAbsolutePath() + File.separator + "assets" + File.separator + "images" + File.separator + "products";
            File dir = new File(localSourcePath);
            if (!dir.exists()) dir.mkdirs();
            return localSourcePath;
        }

        // -----------------------------------------------------------
        // 策略 3: 保底方案 (存到 Tomcat 临时运行目录)
        // -----------------------------------------------------------
        // 如果上面都没找到，就存到当前的运行目录里 (重启可能会丢失，但能保证程序不报错)
        String fallbackPath = context.getRealPath("/") + "assets" + File.separator + "images" + File.separator + "products";
        File dir = new File(fallbackPath);
        if (!dir.exists()) dir.mkdirs();
        return fallbackPath;
    }
}