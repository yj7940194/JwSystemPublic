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
      width="560px"
    >
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="90px">
        <el-form-item label="账号" prop="id">
          <el-input v-model="form.id" style="width: 420px;" :disabled="crud.status.edit === 1" />
        </el-form-item>
        <el-form-item label="姓名" prop="username">
          <el-input v-model="form.username" style="width: 420px;" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password style="width: 420px;" />
        </el-form-item>
        <el-form-item label="角色" prop="qx">
          <el-select v-model="form.qx" placeholder="请选择" style="width: 420px;">
            <el-option v-for="r in roleOptions" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item label="所属学院" prop="collegeId">
          <el-select v-model="form.collegeId" placeholder="请选择" clearable style="width: 420px;">
            <el-option v-for="c in colleges" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="1">激活</el-radio>
            <el-radio label="0">锁定</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="form.phone" style="width: 420px;" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" style="width: 420px;" />
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
      <el-table-column prop="id" label="账号" width="90" />
      <el-table-column prop="username" label="姓名" />
      <el-table-column prop="qx" label="角色" width="110" />
      <el-table-column prop="collegeName" label="学院" />
      <el-table-column prop="status" label="状态" width="90" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === '1' ? 'success' : 'danger'">{{ scope.row.status === '1' ? '激活' : '锁定' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="phone" label="电话" width="140" />
      <el-table-column prop="email" label="邮箱" />
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
import userApi from "@/api/admin/user/user";

const defaultCrud = CRUD({
  title: "用户",
  url: "api/user/pageQuery",
  idField: "id",
  sort: "id,desc",
  crudMethod: { ...userApi }
});
const defaultForm = {
  id: null,
  username: "",
  password: "",
  qx: "",
  status: "1",
  collegeId: null,
  phone: "",
  email: ""
};

export default {
  name: "AdminUser",
  components: { pagination, crudOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      colleges: [],
      roleOptions: ["管理员", "教务人员", "教师", "学生"],
      permission: {
        add: ["admin", "user:add"],
        edit: ["admin", "user:edit"],
        del: ["admin", "user:del"]
      },
      rules: {
        id: [{ required: true, message: "请输入账号", trigger: "blur" }],
        qx: [{ required: true, message: "请选择角色", trigger: "change" }],
        password: [
          {
            validator: (rule, value, callback) => this.validatePassword(rule, value, callback),
            trigger: "blur"
          }
        ]
      }
    };
  },
  created() {
    this.loadColleges();
  },
  methods: {
    validatePassword(rule, value, callback) {
      if (this.crud.status.add === CRUD.STATUS.PREPARED && (!value || !String(value).trim())) {
        callback(new Error("请输入密码"));
        return;
      }
      callback();
    },
    [CRUD.HOOK.beforeToEdit](crud, form) {
      form.password = "";
    },
    async loadColleges() {
      try {
        const list = await userApi.listajax();
        this.colleges = list || [];
      } catch (e) {
        this.colleges = [];
      }
    }
  }
};
</script>
