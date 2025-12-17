package com.zxw.common.pojo;
import java.io.Serializable;

public class MenuMeta implements Serializable {
    private String title;
    private String icon;

    public MenuMeta(String title, String icon) {
        this.title = title;
        this.icon = icon;
    }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
}
