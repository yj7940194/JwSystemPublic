<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>培养方案列表</span>
      </div>
      
      <div class="filter-container" style="margin-bottom: 20px;">
        <el-input v-model="query.name" placeholder="方案名称" style="width: 200px;" class="filter-item" @keyup.enter.native="loadData"/>
        <el-button type="primary" icon="el-icon-search" @click="loadData">搜索</el-button>
      </div>

      <el-table
        :data="dataList"
        v-loading="loading"
        border
        style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center"/>
        <el-table-column prop="name" label="方案名称" min-width="150"/>
        <el-table-column prop="dept" label="所属系部" width="150" align="center"/>
        <el-table-column prop="specialty" label="专业" width="150" align="center"/>
        <el-table-column prop="grade" label="年级" width="100" align="center"/>
        <el-table-column prop="term" label="学期" width="120" align="center"/>
        <el-table-column label="操作" width="100" align="center">
          <template slot-scope="scope">
             <el-button type="text" size="small" @click="$message.info('详情功能开发中')">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "StudentPlan",
  data() {
    return {
      dataList: [],
      loading: false,
      query: {
        page: 1,
        size: 20,
        name: ''
      }
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      request.get('/api/plan/listajax', { params: this.query })
        .then(res => {
           // 处理可能的返回结构 mismatch
           const data = res.data;
           if (Array.isArray(data)) {
             this.dataList = data;
           } else if (data.rows) {
             this.dataList = data.rows;
           } else {
             this.dataList = [];
           }
        })
        .catch(err => {
          console.error(err);
          this.$message.error('获取培养方案失败');
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
