<template>
  <div class="app-container">
    <el-card class="box-card" v-loading="loading">
      <div slot="header">
        <span>个人信息</span>
        <el-button style="float: right" type="text" @click="loadData">刷新</el-button>
      </div>

      <el-empty v-if="!userInfo || !userInfo.id" description="正在加载个人信息..."></el-empty>

      <div v-if="userInfo && userInfo.id">
        <div class="user-profile">
          <div class="user-name">{{ userInfo.username || userInfo.tname || userInfo.name }}</div>
          <div class="user-role">{{ userInfo.qx || '教师' }}</div>
        </div>

        <el-descriptions title="基本资料" :column="2" border style="margin-top: 20px">
          <el-descriptions-item label="工号">{{ userInfo.id || userInfo.tid }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ userInfo.username || userInfo.tname || userInfo.name }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ userInfo.sex || userInfo.tsex }}</el-descriptions-item>
          <el-descriptions-item label="所属院系">{{ userInfo.collegeId || userInfo.college_id || '-' }}</el-descriptions-item>
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
  name: 'TeacherInfo',
  data() {
    return {
      userInfo: null,
      loading: false
    }
  },
  mounted() {
    this.loadData()
  },
  methods: {
    loadData() {
      this.loading = true
      request
        .get('/api/teacher/findById')
        .then((res) => {
          const payload = res && res.data ? res.data : res
          this.userInfo = payload
        })
        .catch((err) => {
          console.error('获取个人信息失败:', err && err.message ? err.message : err)
          this.$message.error('获取个人信息失败')
        })
        .finally(() => {
          this.loading = false
        })
    }
  }
}
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
