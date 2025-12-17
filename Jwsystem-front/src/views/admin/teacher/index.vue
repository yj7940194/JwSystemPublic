<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <!-- 搜索 -->
        <el-input v-model="query.username" clearable size="small" placeholder="输入教师姓名搜索" style="width: 200px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表单组件-->
    <el-dialog :close-on-click-modal="false" :before-close="crud.cancelCU" :visible.sync="crud.status.cu > 0" :title="crud.status.title" width="570px">
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="80px">
        <el-form-item label="姓名" prop="username">
          <el-input v-model="form.username" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="所属学院" prop="collegeId">
          <el-select v-model="form.collegeId" placeholder="请选择" style="width: 370px;">
            <el-option
              v-for="item in colleges"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="性别" prop="tsex">
          <el-radio-group v-model="form.tsex">
            <el-radio label="男">男</el-radio>
            <el-radio label="女">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="年龄" prop="tage">
          <el-input v-model="form.tage" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="身份证" prop="idcard">
          <el-input v-model="form.idcard" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择" style="width: 370px;">
            <el-option label="在职" value="0" />
            <el-option label="辞职" value="1" />
            <el-option label="离职" value="2" />
          </el-select>
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
      <el-table-column prop="username" label="姓名" />
      <el-table-column prop="collegeName" label="所属学院" />
      <el-table-column prop="tsex" label="性别" />
      <el-table-column prop="tage" label="年龄" />
      <el-table-column prop="status" label="状态" align="center">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === '0'" type="success">在职</el-tag>
          <el-tag v-else-if="scope.row.status === '1'" type="warning">辞职</el-tag>
          <el-tag v-else type="danger">离职</el-tag>
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
import crudTeacher from '@/api/admin/teacher'
import { getAll as getColleges } from '@/api/admin/college'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import udOperation from '@crud/UD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '教师', url: 'api/teacher/pageQuery', idField: 'id', sort: 'tid,desc', crudMethod: { ...crudTeacher } })
const defaultForm = { id: null, username: '', collegeId: null, tsex: '男', tage: '', status: '0', idcard: '' }

export default {
  name: 'Teacher',
  components: { pagination, crudOperation, rrOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      colleges: [],
      permission: {
        add: ['admin', 'teacher:add'],
        edit: ['admin', 'teacher:edit'],
        del: ['admin', 'teacher:del']
      },
      rules: {
        username: [
          { required: true, message: '请输入教师姓名', trigger: 'blur' }
        ],
        collegeId: [
          { required: true, message: '请选择所属学院', trigger: 'change' }
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