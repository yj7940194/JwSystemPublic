<template>
  <div class="app-container">
    <div class="head-container">
      <el-select v-model="query.specialtyId" placeholder="请选择专业" style="width: 200px; margin-right: 10px;">
        <el-option
          v-for="item in specialties"
          :key="item.id"
          :label="item.name"
          :value="item.id"
        />
      </el-select>
      <el-date-picker v-model="query.yearId" type="year" value-format="yyyy" placeholder="选择学年" style="width: 200px; margin-right: 10px;" />
      <el-button type="primary" icon="el-icon-search" @click="handleQuery">查询教学计划</el-button>
    </div>

    <el-card v-if="hasQueried" style="margin-top: 20px;">
      <div slot="header" class="clearfix">
        <span>{{ form.id ? '编辑教学计划' : '新增教学计划' }}</span>
      </div>
      <el-form ref="form" :model="form" label-width="80px">
        <el-form-item label="名称">
          <el-input v-model="form.name" style="width: 400px;" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input type="textarea" :rows="10" v-model="form.htmlName" placeholder="请输入教学计划内容" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSave">保存</el-button>
          <el-button type="danger" v-if="form.id" @click="handleDelete">删除</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { find, add, edit, del } from '@/api/admin/program'
import { getAll as getSpecialties } from '@/api/admin/specialty'

export default {
  name: 'Program',
  data() {
    return {
      specialties: [],
      query: {
        specialtyId: '',
        yearId: ''
      },
      form: {
        id: null,
        name: '',
        htmlName: '',
        specialtyId: '',
        yearId: ''
      },
      hasQueried: false
    }
  },
  created() {
    this.getSpecialties()
  },
  methods: {
    getSpecialties() {
      getSpecialties().then(res => {
        this.specialties = res
      })
    },
    handleQuery() {
      if (!this.query.specialtyId || !this.query.yearId) {
        this.$message.warning('请选择专业和学年')
        return
      }
      find(this.query).then(res => {
        this.hasQueried = true
        if (res) {
          this.form = { ...res }
        } else {
          // Reset form for new entry
          this.form = {
            id: null,
            name: '',
            htmlName: '',
            specialtyId: this.query.specialtyId,
            yearId: this.query.yearId
          }
        }
      })
    },
    handleSave() {
      if (!this.form.name) {
        this.$message.warning('请输入名称')
        return
      }
      const op = this.form.id ? edit : add
      op(this.form).then(() => {
        this.$message.success('保存成功')
        this.handleQuery() // Refresh
      })
    },
    handleDelete() {
      this.$confirm('确认删除该教学计划?', '提示', {
        type: 'warning'
      }).then(() => {
        del(this.form.id).then(() => {
          this.$message.success('删除成功')
          this.handleQuery()
        })
      })
    }
  }
}
</script>