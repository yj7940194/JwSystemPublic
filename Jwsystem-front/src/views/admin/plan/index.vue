<template>
  <div class="app-container">
    <!--工具栏-->
    <div class="head-container">
      <div v-if="crud.props.searchToggle">
        <!-- 搜索 -->
        <el-input v-model="query.name" clearable size="small" placeholder="输入名称搜索" style="width: 200px;" class="filter-item" @keyup.enter.native="crud.toQuery" />
        <rrOperation :crud="crud" />
      </div>
      <crudOperation :permission="permission" />
    </div>
    <!--表单组件-->
    <el-dialog :close-on-click-modal="false" :before-close="crud.cancelCU" :visible.sync="crud.status.cu > 0" :title="crud.status.title" width="500px">
      <el-form ref="form" :model="form" :rules="rules" size="small" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" style="width: 370px;" />
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
        <el-form-item label="学年" prop="yearId">
          <el-date-picker v-model="form.yearId" type="year" value-format="yyyy" placeholder="选择年" style="width: 370px;" />
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
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="sname" label="所属专业" />
      <el-table-column prop="yearId" label="学年" />
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
import crudPlan from '@/api/admin/plan'
import { getAll as getSpecialties } from '@/api/admin/specialty'
import CRUD, { presenter, header, form, crud } from '@crud/crud'
import rrOperation from '@crud/RR.operation'
import crudOperation from '@crud/CRUD.operation'
import udOperation from '@crud/UD.operation'
import pagination from '@crud/Pagination'

const defaultCrud = CRUD({ title: '执行计划', url: 'api/plan/listajax', idField: 'id', sort: 'id,desc', crudMethod: { ...crudPlan } })
const defaultForm = { id: null, name: '', specialtyId: null, yearId: '' }

export default {
  name: 'Plan',
  components: { pagination, crudOperation, rrOperation, udOperation },
  mixins: [presenter(defaultCrud), header(), form(defaultForm), crud()],
  data() {
    return {
      specialties: [],
      permission: {
        add: ['admin', 'plan:add'],
        edit: ['admin', 'plan:edit'],
        del: ['admin', 'plan:del']
      },
      rules: {
        name: [
          { required: true, message: '请输入名称', trigger: 'blur' }
        ],
        specialtyId: [
          { required: true, message: '请选择专业', trigger: 'change' }
        ]
      }
    }
  },
  methods: {
    [CRUD.HOOK.beforeToCU](crud, form) {
      this.getSpecialties()
    },
    getSpecialties() {
      getSpecialties().then(res => {
        const payload = res && res.data ? res.data : res
        this.specialties = Array.isArray(payload)
          ? payload
          : (payload && Array.isArray(payload.rows) ? payload.rows : [])
      })
    }
  }
}
</script>
