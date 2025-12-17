<template>
  <div class="app-container">
    <div class="head-container">
      <crudOperation :permission="permission" />
    </div>

    <el-dialog
      :close-on-click-modal="false"
      :before-close="crud.cancelCU"
      :visible.sync="crud.status.cu > 0"
      :title="crud.status.title"
      width="620px"
    >
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="90px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" style="width: 460px;" />
        </el-form-item>
        <el-form-item label="路径" prop="path">
          <el-input v-model="form.path" style="width: 460px;" />
        </el-form-item>
        <el-form-item label="组件" prop="component">
          <el-input v-model="form.component" style="width: 460px;" />
        </el-form-item>
        <el-form-item label="上级ID" prop="pid">
          <el-input-number v-model="form.pid" :min="0" :step="1" style="width: 200px;" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-radio-group v-model="form.type">
            <el-radio :label="0">目录</el-radio>
            <el-radio :label="1">页面</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="权限标识" prop="permission">
          <el-input v-model="form.permission" style="width: 460px;" />
        </el-form-item>
        <el-form-item label="图标" prop="icon">
          <el-input v-model="form.icon" style="width: 460px;" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="form.sort" :min="0" :step="1" style="width: 200px;" />
        </el-form-item>
        <el-form-item label="隐藏">
          <el-switch v-model="form.hidden" />
        </el-form-item>
        <el-form-item label="缓存">
          <el-switch v-model="form.cache" />
        </el-form-item>
        <el-form-item label="外链">
          <el-switch v-model="form.iFrame" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="text" @click="crud.cancelCU">取消</el-button>
        <el-button :loading="crud.cu === 2" type="primary" @click="crud.submitCU">确认</el-button>
      </div>
    </el-dialog>

    <el-table
      ref="table"
      v-loading="crud.loading"
      :data="crud.data"
      size="small"
      style="width: 100%;"
      @selection-change="crud.selectionChangeHandler"
    >
      <el-table-column type="selection" width="55" />
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="type" label="类型" width="80" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.type === 0 ? 'info' : 'success'">{{ scope.row.type === 0 ? '目录' : '页面' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="path" label="路径" show-overflow-tooltip />
      <el-table-column prop="component" label="组件" show-overflow-tooltip />
      <el-table-column prop="pid" label="PID" width="80" />
      <el-table-column prop="permission" label="权限标识" width="140" show-overflow-tooltip />
      <el-table-column prop="sort" label="排序" width="80" />
      <el-table-column label="操作" width="150px" align="center">
        <template slot-scope="scope">
          <udOperation :data="scope.row" :permission="permission" />
        </template>
      </el-table-column>
    </el-table>

    <pagination />
  </div>
</template>

<script>
import CRUD, { presenter, header, form, crud } from "@crud/crud";
import crudOperation from "@crud/CRUD.operation";
import udOperation from "@crud/UD.operation";
import pagination from "@crud/Pagination";
import menuApi from "@/api/admin/menu/menu";

const defaultCrud = CRUD({
  title: "权限",
  url: "api/menu/listajax",
  idField: "id",
  sort: "id,desc",
  crudMethod: { ...menuApi }
});

const defaultForm = {
  id: null,
  name: "",
  path: "",
  component: "",
  pid: 0,
  type: 1,
  permission: "",
  icon: "",
  sort: 0,
  hidden: false,
  cache: false,
  iFrame: false
};

export default {
  name: "AdminMenu",
  components: { pagination, crudOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      permission: {
        add: ["admin", "menu:add"],
        edit: ["admin", "menu:edit"],
        del: ["admin", "menu:del"]
      },
      rules: {
        name: [{ required: true, message: "请输入名称", trigger: "blur" }]
      }
    };
  }
};
</script>

