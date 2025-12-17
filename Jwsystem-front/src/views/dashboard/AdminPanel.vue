<template>
  <div class="admin-dashboard">
    <el-row :gutter="16">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="never" class="stat-card" v-loading="loading">
          <div class="label">学生总数</div>
          <div class="value">{{ stats.students }}</div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="never" class="stat-card" v-loading="loading">
          <div class="label">教师总数</div>
          <div class="value">{{ stats.teachers }}</div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="never" class="stat-card" v-loading="loading">
          <div class="label">课程总数</div>
          <div class="value">{{ stats.courses }}</div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="never" class="stat-card" v-loading="loading">
          <div class="label">评价批次</div>
          <div class="value">{{ stats.commentBatches }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="mt-2">
      <div slot="header" class="clearfix">
        <span>说明</span>
      </div>
      <el-alert
        type="info"
        show-icon
        :closable="false"
        title="首页默认展示系统概览数据（学生/教师/课程/评价批次）。如需运行监控图表，可单独放到“系统监控”页面。"
      />
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'AdminPanel',
  data() {
    return {
      loading: false,
      stats: {
        students: 0,
        teachers: 0,
        courses: 0,
        commentBatches: 0
      }
    }
  },
  created() {
    this.fetchStats()
  },
  methods: {
    async fetchStats() {
      this.loading = true
      try {
        const [students, teachers, courses, commentBatches] = await Promise.all([
          request({ url: 'api/student/pageQuery', method: 'get', params: { offset: 1, limit: 1 } }),
          request({ url: 'api/teacher/pageQuery', method: 'get', params: { offset: 1, limit: 1 } }),
          request({ url: 'api/course/pageQuery', method: 'get', params: { offset: 1, limit: 1 } }),
          request({ url: 'api/comment/pageQuery', method: 'get', params: { offset: 1, limit: 1 } })
        ])

        this.stats.students = (students && Number(students.total)) || 0
        this.stats.teachers = (teachers && Number(teachers.total)) || 0
        this.stats.courses = (courses && Number(courses.total)) || 0
        this.stats.commentBatches = (commentBatches && Number(commentBatches.total)) || 0
      } catch (e) {
        if (this.$message) this.$message.error('首页概览数据加载失败')
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.admin-dashboard {
  width: 100%;
}

.stat-card {
  min-height: 92px;
}

.label {
  color: #909399;
  font-size: 12px;
  line-height: 18px;
}

.value {
  margin-top: 6px;
  font-size: 26px;
  font-weight: 700;
  color: #303133;
  line-height: 32px;
}

.mt-2 {
  margin-top: 12px;
}
</style>
