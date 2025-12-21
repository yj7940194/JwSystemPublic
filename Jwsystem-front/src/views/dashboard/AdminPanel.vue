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

    <el-row :gutter="16" class="mt-2">
      <el-col :xs="24" :md="14">
        <el-card shadow="never" class="card">
          <div slot="header" class="clearfix">
            <span>快捷入口</span>
          </div>
          <div class="quick-actions">
            <el-button size="small" type="primary" plain @click="go('/admin/college')">学院管理</el-button>
            <el-button size="small" type="primary" plain @click="go('/admin/specialty')">专业管理</el-button>
            <el-button size="small" type="primary" plain @click="go('/admin/classes')">班级管理</el-button>
            <el-button size="small" type="success" plain @click="go('/admin/plan')">教学执行</el-button>
            <el-button size="small" type="success" plain @click="go('/admin/program')">培养方案</el-button>
            <el-button size="small" type="warning" plain @click="go('/admin/score')">成绩统计</el-button>
            <el-button size="small" type="info" plain @click="go('/admin/user')">用户管理</el-button>
          </div>
          <div class="tips">
            <span>提示：</span>
            <span>右上角可进入个人中心/退出登录；菜单支持搜索。</span>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :md="10">
        <el-card shadow="never" class="card">
          <div slot="header" class="clearfix">
            <span>说明</span>
          </div>
          <el-alert
            type="info"
            show-icon
            :closable="false"
            title="首页展示系统概览与常用入口。若数据为空，可先导入初始化 SQL 或执行 demo seed。"
          />
        </el-card>
      </el-col>
    </el-row>
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
    go(path) {
      if (this.$router && path) this.$router.push({ path })
    },
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

.card {
  border-radius: 10px;
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

.quick-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.tips {
  margin-top: 12px;
  color: #909399;
  font-size: 12px;
}
</style>
