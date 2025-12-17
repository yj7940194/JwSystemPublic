package com.zxw.common.pojo;
import java.io.Serializable;
import java.util.List;

public class MenuNode implements Serializable {
    private Long id;
    private String name;
    private String component;
    private String path;
    private String redirect;
    private Boolean hidden;
    private Long pid;
    private Boolean alwaysShow;
    private MenuMeta meta;
    private List<MenuNode> children;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getComponent() { return component; }
    public void setComponent(String component) { this.component = component; }
    public String getPath() { return path; }
    public void setPath(String path) { this.path = path; }
    public String getRedirect() { return redirect; }
    public void setRedirect(String redirect) { this.redirect = redirect; }
    public Boolean getHidden() { return hidden; }
    public void setHidden(Boolean hidden) { this.hidden = hidden; }
    public Long getPid() { return pid; }
    public void setPid(Long pid) { this.pid = pid; }
    public Boolean getAlwaysShow() { return alwaysShow; }
    public void setAlwaysShow(Boolean alwaysShow) { this.alwaysShow = alwaysShow; }
    public MenuMeta getMeta() { return meta; }
    public void setMeta(MenuMeta meta) { this.meta = meta; }
    public List<MenuNode> getChildren() { return children; }
    public void setChildren(List<MenuNode> children) { this.children = children; }
}