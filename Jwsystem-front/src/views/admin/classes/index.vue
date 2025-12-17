<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <!-- 搜索 -->
        <el-input v-model="query.classname" clearable size="small" placeholder="输入班级名称搜索" style="width: 200px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表单组件-->
    <el-dialog :close-on-click-modal="false" :before-close="crud.cancelCU" :visible.sync="crud.status.cu > 0" :title="crud.status.title" width="500px">
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="80px">
        <el-form-item label="班级名称" prop="classname">
          <el-input v-model="form.classname" style="width: 370px;" />
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
        <el-form-item label="所属专业" prop="specialtyId">
          <el-select v-model="form.specialtyId" placeholder="请选择" style="width: 370px;">
            <el-option
              v-for="item in specialties"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="人数" prop="people">
          <el-input v-model="form.people" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="年级" prop="gradeId">
          <el-input v-model="form.gradeId" placeholder="例如: 2019级" style="width: 370px;" />
        </el-form-item>
        <el-form-item label="入学年份" prop="year">
          <el-date-picker v-model="form.year" type="year" value-format="yyyy" placeholder="选择年" style="width: 370px;" />
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
      <el-table-column prop="classname" label="班级名称" />
      <el-table-column prop="cname" label="学院" />
      <el-table-column prop="sname" label="专业" />
      <el-table-column prop="people" label="人数" />
      <el-table-column prop="gradeId" label="年级" />
      <el-table-column prop="year" label="入学年份" />
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
import crudClasses from '@/api/admin/classes'
import { getAll as getColleges } from '@/api/admin/college'
import { getAll as getSpecialties } from '@/api/admin/specialty'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import udOperation from '@crud/UD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '班级', url: 'api/classes/pageQuery', idField: 'id', sort: 'id,desc', crudMethod: { ...crudClasses } })
const defaultForm = { id: null, classname: '', collegeId: null, specialtyId: null, people: 0, gradeId: '', year: '' }

export default {
  name: 'Classes',
  components: { pagination, crudOperation, rrOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      colleges: [],
      specialties: [],
      permission: {
        add: ['admin', 'classes:add'],
        edit: ['admin', 'classes:edit'],
        del: ['admin', 'classes:del']
      },
      rules: {
        classname: [
          { required: true, message: '请输入班级名称', trigger: 'blur' }
        ],
        collegeId: [
          { required: true, message: '请选择所属学院', trigger: 'change' }
        ],
        specialtyId: [
          { required: true, message: '请选择所属专业', trigger: 'change' }
        ]
      }
    }
  },
  methods: {
    [CRUD.HOOK.beforeToCU](crud, form) {
      this.getColleges()
      this.getSpecialties()
    },
    getColleges() {
      getColleges().then(res => {
        this.colleges = res
      })
    },
    getSpecialties() {
      getSpecialties().then(res => {
        this.specialties = res
      })
    }
  }
}
</script>