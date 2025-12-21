<template>
  <div class="app-container">
    <el-card v-loading="loading">
      <div slot="header">
        <span>教学方案详情</span>
      </div>
      
      <el-empty v-if="!program" description="未找到当前专业的教学方案"></el-empty>

      <div v-else>
        <el-descriptions title="基本信息" :column="2" border>
          <el-descriptions-item label="方案ID">{{ program.id }}</el-descriptions-item>
          <el-descriptions-item label="专业代码">{{ program.specialtyId }}</el-descriptions-item>
          <el-descriptions-item label="学年">{{ program.yearId || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ Number(program.status) === 1 ? '启用' : '停用' }}</el-descriptions-item>
        </el-descriptions>

        <el-divider content-position="left">方案内容</el-divider>

        <div v-if="program.htmlName" class="program-html" v-html="program.htmlName"></div>
        <div v-else class="program-text">{{ program.name }}</div>
      </div>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "StudentProgram",
  data() {
    return {
      program: null,
      loading: false
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      request.get('/api/program/findProgram')
        .then(res => {
          const payload = res && res.data ? res.data : res
          this.program = payload || null
        })
        .catch(err => {
          console.error(err);
          this.$message.error('获取教学方案失败');
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
.program-text {
  white-space: pre-wrap;
  line-height: 1.8;
  color: #303133;
}
.program-html :deep(p) {
  margin: 0 0 10px;
}
</style>
