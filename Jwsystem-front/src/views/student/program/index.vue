<template>
  <div class="app-container">
    <el-card v-loading="loading">
      <div slot="header">
        <span>教学方案详情</span>
      </div>
      
      <div v-if="program">
        <el-descriptions title="基本信息" :column="2" border>
          <el-descriptions-item label="方案名称">{{ program.name }}</el-descriptions-item>
          <el-descriptions-item label="专业代码">{{ program.specialtyId }}</el-descriptions-item>
          <el-descriptions-item label="培养目标" :span="2">{{ program.target || '暂无描述' }}</el-descriptions-item>
          <el-descriptions-item label="修读要求" :span="2">{{ program.require || '暂无描述' }}</el-descriptions-item>
        </el-descriptions>
        
        <el-divider content-position="left">课程设置</el-divider>
        
        <el-empty v-if="!program.courses" description="暂无课程信息"></el-empty>
        
        <!-- 这里假设program对象里没有直接带课程列表，通常需要额外查询 -->
        <el-alert title="课程列表需根据方案ID进一步查询" type="info" :closable="false" show-icon style="margin-top:20px"/>
      </div>
      
      <el-empty v-else description="未找到当前专业的教学方案"></el-empty>
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
          this.program = res.data;
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
</style>
