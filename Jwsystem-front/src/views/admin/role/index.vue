<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="14">
        <div class="head-container">
          <crudOperation :permission="permission" />
        </div>

        <el-dialog
          :close-on-click-modal="false"
          :before-close="crud.cancelCU"
          :visible.sync="crud.status.cu > 0"
          :title="crud.status.title"
          width="520px"
        >
          <el-form ref="form" :model="form" :rules="rules" size="small" label-width="90px">
            <el-form-item label="角色名称" prop="name">
              <el-input v-model="form.name" style="width: 380px;" />
            </el-form-item>
            <el-form-item label="角色编码" prop="code">
              <el-input v-model="form.code" style="width: 380px;" />
            </el-form-item>
            <el-form-item label="描述" prop="description">
              <el-input v-model="form.description" type="textarea" :rows="3" style="width: 380px;" />
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
          highlight-current-row
          @selection-change="crud.selectionChangeHandler"
          @current-change="handleRoleChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="name" label="角色名称" />
          <el-table-column prop="code" label="角色编码" />
          <el-table-column prop="description" label="描述" show-overflow-tooltip />
          <el-table-column label="操作" width="150px" align="center">
            <template slot-scope="scope">
              <udOperation :data="scope.row" :permission="permission" />
            </template>
          </el-table-column>
        </el-table>
        <pagination />
      </el-col>

      <el-col :span="10">
        <el-card shadow="never" class="menu-card">
          <div slot="header" class="menu-card__header">
            <span>菜单权限</span>
            <el-button
              size="mini"
              type="primary"
              :disabled="!currentRole || menuLoading"
              :loading="menuSaving"
              @click="saveRoleMenus"
            >保存</el-button>
          </div>

          <div v-if="!currentRole" class="menu-card__empty">
            请选择左侧角色以配置菜单权限
          </div>

          <el-tree
            v-else
            ref="menuTree"
            v-loading="menuLoading"
            :data="menuTree"
            show-checkbox
            node-key="id"
            :default-expand-all="true"
            :props="treeProps"
          />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import CRUD, { presenter, header, form, crud } from "@crud/crud";
import crudOperation from "@crud/CRUD.operation";
import udOperation from "@crud/UD.operation";
import pagination from "@crud/Pagination";
import roleApi from "@/api/admin/role/role";
import menuApi from "@/api/admin/menu/menu";

const defaultCrud = CRUD({
  title: "角色",
  url: "api/role/listajax",
  idField: "id",
  sort: "id,desc",
  crudMethod: { ...roleApi }
});
const defaultForm = { id: null, name: "", code: "", description: "" };

export default {
  name: "AdminRole",
  components: { pagination, crudOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      permission: {
        add: ["admin", "role:add"],
        edit: ["admin", "role:edit"],
        del: ["admin", "role:del"]
      },
      rules: {
        name: [{ required: true, message: "请输入角色名称", trigger: "blur" }]
      },
      currentRole: null,
      menuTree: [],
      treeProps: { children: "children", label: "name" },
      menuLoading: false,
      menuSaving: false
    };
  },
  created() {
    this.loadMenus();
  },
  methods: {
    buildMenuTree(list) {
      const nodes = new Map();
      for (const item of Array.isArray(list) ? list : []) {
        nodes.set(item.id, { ...item, children: [] });
      }

      const roots = [];
      for (const node of nodes.values()) {
        const pid = node.pid;
        if (!pid || !nodes.has(pid)) {
          roots.push(node);
        } else {
          nodes.get(pid).children.push(node);
        }
      }

      const sortChildren = (arr) => {
        arr.sort((a, b) => (a.sort || 0) - (b.sort || 0));
        for (const n of arr) {
          if (Array.isArray(n.children) && n.children.length) {
            sortChildren(n.children);
          }
        }
      };
      sortChildren(roots);

      return roots;
    },
    async loadMenus() {
      this.menuLoading = true;
      try {
        const list = await menuApi.listajaxMenu();
        this.menuTree = this.buildMenuTree(list || []);
      } finally {
        this.menuLoading = false;
      }
    },
    async handleRoleChange(row) {
      if (!row || !row.id) {
        this.currentRole = null;
        return;
      }
      this.currentRole = row;
      await this.loadRoleMenus(row.id);
    },
    async loadRoleMenus(roleId) {
      if (!this.$refs.menuTree) {
        return;
      }
      this.$refs.menuTree.setCheckedKeys([]);
      const list = await roleApi.findMenuByRole(roleId);
      const ids = Array.isArray(list) ? list.map((m) => m.id).filter(Boolean) : [];
      this.$nextTick(() => {
        this.$refs.menuTree && this.$refs.menuTree.setCheckedKeys(ids);
      });
    },
    async saveRoleMenus() {
      if (!this.currentRole || !this.currentRole.id || !this.$refs.menuTree) {
        return;
      }
      this.menuSaving = true;
      try {
        const checked = this.$refs.menuTree.getCheckedKeys() || [];
        const half = this.$refs.menuTree.getHalfCheckedKeys
          ? this.$refs.menuTree.getHalfCheckedKeys()
          : [];
        const ids = Array.from(new Set([...checked, ...half])).map(String);
        await roleApi.saveMenu({ roleId: this.currentRole.id, menuIds: ids });
        this.$message({ message: "保存成功", type: "success" });
      } finally {
        this.menuSaving = false;
      }
    }
  }
};
</script>

<style lang="scss" scoped>
.menu-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.menu-card__empty {
  padding: 12px;
  color: #909399;
}
</style>

