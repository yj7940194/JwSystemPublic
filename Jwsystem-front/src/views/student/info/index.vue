<template>
  <div class="app-container">
    <el-card class="box-card" v-loading="loading">
      <div slot="header">
        <span>{{ isStudent ? '学籍卡片' : '学籍卡片（学生档案预览）' }}</span>
        <el-select
          v-if="!isStudent"
          v-model="selectedStudentId"
          filterable
          clearable
          placeholder="选择/搜索学生（学号/姓名）"
          style="width: 260px; margin-left: 12px;"
          @change="applySelectedStudent"
        >
          <el-option
            v-for="item in studentOptions"
            :key="item.sid || item.id"
            :label="`${item.sname || item.username || item.sid || item.id}` + (item.sid || item.id ? `（${item.sid || item.id}）` : '')"
            :value="item.sid || item.id"
          />
        </el-select>
        <el-button style="float: right" type="text" @click="loadData">刷新</el-button>
      </div>

      <el-alert
        v-if="!isStudent"
        type="info"
        :closable="false"
        show-icon
        title="说明"
        description="该页面用于查看学生学籍档案。教务/管理员可在上方选择学生；学生账号默认展示本人信息。"
        style="margin-bottom: 12px;"
      />
      
      <el-empty v-if="!userInfo || !(userInfo.id || userInfo.sid)" description="正在加载学籍信息..."></el-empty>
      
      <div v-if="userInfo && (userInfo.id || userInfo.sid)">
        <div class="user-profile">
          <div class="user-name">{{ userInfo.username || userInfo.sname }}</div>
          <div class="user-role">{{ userInfo.qx || '学生' }}</div>
        </div>

        <el-descriptions title="基本资料" :column="2" border style="margin-top: 20px">
          <el-descriptions-item label="学号">{{ userInfo.id || userInfo.sid }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ userInfo.username || userInfo.sname }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ userInfo.sex }}</el-descriptions-item>
          <el-descriptions-item label="班级ID">{{ userInfo.classesId || userInfo.classes_id }}</el-descriptions-item>
          <el-descriptions-item label="年级">{{ userInfo.gradeId || userInfo.grade_id }}级</el-descriptions-item>
          <el-descriptions-item label="生源地">{{ userInfo.scity }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ userInfo.phone || '未填写' }}</el-descriptions-item>
          <el-descriptions-item label="身份证号">{{ userInfo.idcard || '未填写' }}</el-descriptions-item>
          <el-descriptions-item label="家庭住址" :span="2">{{ userInfo.address || '未填写' }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: "StudentInfo",
  data() {
    return {
      userInfo: null,
      loading: false,
      selectedStudentId: '',
      studentOptions: []
    };
  },
  computed: {
    isStudent() {
      const u = this.$store && this.$store.state && this.$store.state.user && this.$store.state.user.user
      return u && u.qx === '学生'
    }
  },
  mounted() {
    this.loadData();
  },
  methods: {
    applySelectedStudent() {
      if (!this.selectedStudentId) {
        this.userInfo = null
        return
      }
      const hit = this.studentOptions.find(s => (s.sid || s.id) === this.selectedStudentId)
      if (hit) this.userInfo = hit
    },
    loadData() {
      this.loading = true;
      const task = this.isStudent
        ? request.get('/api/student/findInfo').then(res => {
          const payload = res && res.data ? res.data : res
          this.userInfo = payload
        })
        : request.get('/api/student/pageQuery', { params: { offset: 1, limit: 200 } }).then(res => {
          const rows = (res && (res.rows || res.content)) || []
          this.studentOptions = Array.isArray(rows) ? rows : []
          if (!this.studentOptions.length) {
            this.userInfo = null
            return
          }
          if (!this.selectedStudentId) {
            this.selectedStudentId = this.studentOptions[0].sid || this.studentOptions[0].id
          }
          this.applySelectedStudent()
        })

      task
        .catch(err => {
          console.error('获取个人信息失败:', err && err.message ? err.message : err);
          this.$message.error('获取个人信息失败');
        })
        .finally(() => {
          this.loading = false;
        });
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.user-profile {
  text-align: center;
  margin: 20px 0;
}
.user-name {
  font-weight: bold;
  font-size: 24px;
  margin-bottom: 10px;
}
.user-role {
  color: #777;
}
</style>
