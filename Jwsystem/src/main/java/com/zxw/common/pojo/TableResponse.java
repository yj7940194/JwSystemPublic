package com.zxw.common.pojo;

import com.baomidou.mybatisplus.core.metadata.IPage;
import java.io.Serializable;
import java.util.List;

public class TableResponse implements Serializable {
    private long total;
    private List<?> rows;
    private int code;
    private String msg;

    public static TableResponse of(IPage<?> page) {
        TableResponse response = new TableResponse();
        response.setTotal(page.getTotal());
        response.setRows(page.getRecords());
        response.setCode(0);
        response.setMsg("success");
        return response;
    }

    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    public List<?> getRows() { return rows; }
    public void setRows(List<?> rows) { this.rows = rows; }
    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getMsg() { return msg; }
    public void setMsg(String msg) { this.msg = msg; }
}
