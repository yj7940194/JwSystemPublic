package com.zxw.common.utils;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class FileUtils {
    public static String encodeDownloadFilename(String filename, String agent) {
        try {
            if (agent.contains("Firefox")) {
                filename = "=?UTF-8?B?" + new String(java.util.Base64.getEncoder().encode(filename.getBytes("UTF-8"))) + "?=";
                filename = filename.replaceAll("\r\n", "");
            } else {
                filename = URLEncoder.encode(filename, "UTF-8");
                filename = filename.replace("+", " ");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return filename;
    }
}
