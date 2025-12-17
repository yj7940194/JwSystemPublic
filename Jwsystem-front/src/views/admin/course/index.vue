<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <!-- 搜索 -->
        <el-input v-model="query.name" clearable size="small" placeholder="输入课程名称搜索" style="width: 200px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表单组件-->
    <el-dialog :close-on-click-modal="false" :before-close="crud.cancelCU" :visible.sync="crud.status.cu > 0" :title="crud.status.title" width="570px">
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="80px">
        <el-form-item label="课程名称" prop="name">
          <el-input v-model="form.name" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="学分" prop="credit">
          <el-input v-model="form.credit" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="总学时" prop="totalTime">
          <el-input v-model="form.totalTime" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="开课学院" prop="collegeId">
          <el-select v-model="form.collegeId" placeholder="请选择" style="width: 370px;">
            <el-option
              v-for="item in colleges"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="1">激活</el-radio>
            <el-radio label="0">锁定</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="text" @click="crud.cancelCU">取消</el-button>
        <el-button :loading="crud.cu === 2" type="primary" @click="crud.submitCU">确认</el-button>
      </div>
    </el-dialog>
    <!--表格渲染-->
    <el-table ref="table" v-loading="crud.loading" :data="crud.data" size="small" style="width: 100%;" @selection-change="crud.selectionChangeHandler">
      <el-table-column type="selection" width="55" />
      <el-table-column prop="name" label="课程名称" />
      <el-table-column prop="credit" label="学分" />
      <el-table-column prop="totalTime" label="总学时" />
      <el-table-column prop="cname" label="开课学院" />
      <el-table-column prop="status" label="状态" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">{{ scope.row.status === 1 ? '激活' : '锁定' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150px" align="center">
        <template slot-scope="scope">
          <udOperation
            :data="scope.row"
            :permission="permission"
          />
        </template>
      </el-table-column>
    </el-table>
    <!--分页组件-->
    <pagination />
  </div>
</template>

<script>
import crudCourse from '@/api/admin/course'
import { getAll as getColleges } from '@/api/admin/college'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import udOperation from '@crud/UD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '课程', url: 'api/course/pageQuery', idField: 'id', sort: 'id,desc', crudMethod: { ...crudCourse } })
const defaultForm = { id: null, name: '', credit: '', totalTime: '', collegeId: null, status: 1 }

export default {
  name: 'Course',
  components: { pagination, crudOperation, rrOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      colleges: [],
      permission: {
        add: ['admin', 'course:add'],
        edit: ['admin', 'course:edit'],
        del: ['admin', 'course:del']
      },
      rules: {
        name: [
          { required: true, message: '请输入课程名称', trigger: 'blur' }
        ],
        collegeId: [
          { required: true, message: '请选择开课学院', trigger: 'change' }
        ]
      }
    }
  },
  methods: {
    [CRUD.HOOK.beforeToCU](crud, form) {
      this.getColleges()
    },
    getColleges() {
      getColleges().then(res => {
        this.colleges = res
      })
    }
  }
}
</script>