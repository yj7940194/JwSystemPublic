<template>
  <div class="login">
    <el-form ref="loginForm" :model="loginForm" :rules="loginRules" label-position="left" label-width="0px"
             class="login-form">
      <h3 class="title">
        教务管理系统
      </h3>
      <div class="subtitle">统一入口 · 课程 · 成绩 · 评价</div>
      <el-form-item prop="username">
        <el-input v-model="loginForm.username" type="text" auto-complete="off" placeholder="账号">
          <svg-icon slot="prefix" icon-class="user" class="el-input__icon input-icon"/>
        </el-input>
      </el-form-item>
      <el-form-item prop="password">
        <el-input v-model="loginForm.password" type="password" auto-complete="off" placeholder="密码"
                  @keyup.enter.native="handleLogin">
          <svg-icon slot="prefix" icon-class="password" class="el-input__icon input-icon"/>
        </el-input>
      </el-form-item>
      <el-form-item prop="code">
        <el-input v-model="loginForm.code" auto-complete="off" placeholder="验证码" style="width: 63%"
                  @keyup.enter.native="handleLogin">
          <svg-icon slot="prefix" icon-class="validCode" class="el-input__icon input-icon"/>
        </el-input>
        <div class="login-code">
          <img :src="codeUrl" @click="getCode">
        </div>
      </el-form-item>
      <el-row style="margin-bottom: 10px">
        <el-col :span="6">
          <el-radio v-model="loginForm.RadioButtonList1" label="管理员">管理员</el-radio>
        </el-col>
        <el-col :span="6">
          <el-radio v-model="loginForm.RadioButtonList1" label="教务人员">教务人员</el-radio>
        </el-col>
        <el-col :span="6" :push="2">
          <el-radio v-model="loginForm.RadioButtonList1" label="教师">教师</el-radio>
        </el-col>
        <el-col :span="6">
          <el-radio v-model="loginForm.RadioButtonList1" label="学生">学生</el-radio>
        </el-col>
      </el-row>
      <el-form-item style="width:100%;">
        <el-button :loading="loading" size="medium" type="primary" style="width:100%;"
                   @click.native.prevent="handleLogin">
          <span v-if="!loading">登 录</span>
          <span v-else>登 录 中...</span>
        </el-button>
      </el-form-item>
    </el-form>
    <!--  底部  -->
    <div v-if="$store.state.settings.showFooter" id="el-login-footer">
      <span v-html="$store.state.settings.footerTxt"/>
      <span> ⋅ </span>
      <a href="http://www.beian.miit.gov.cn" target="_blank">{{ $store.state.settings.caseNumber }}</a>
    </div>
  </div>
</template>

<script>
  import Cookies from 'js-cookie'
  import service from '../utils/request'

  export default {
    name: 'Login',
    data() {
      const apiBase = process.env.NODE_ENV === 'development' ? '' : (process.env.VUE_APP_BASE_API || '')
      return {
        apiBase,
        codeUrl: `${apiBase}/kaptcha/create`,
        cookiePass: '',
        loginForm: {
          username: '1',
          password: '123456',
          code: '',
          RadioButtonList1: '教务人员'
        },
        loginRules: {
          username: [{ required: true, trigger: 'blur', message: '用户名不能为空' }],
          password: [{ required: true, trigger: 'blur', message: '密码不能为空' }],
          code: [{ required: true, trigger: 'change', message: '验证码不能为空' }]
        },
        loading: false,
        redirect: undefined
      }
    },
    watch: {
      $route: {
        handler: function(route) {
          this.redirect = route.query && route.query.redirect
        },
        immediate: true
      }
    },
    methods: {
      getCode() {
        this.codeUrl = `${this.apiBase}/kaptcha/create?timestamp=${Date.now()}`
      },
      handleLogin() {
        this.$refs.loginForm.validate(valid => {
          const user = {
            username: this.loginForm.username,
            password: this.loginForm.password,
            checkcode: this.loginForm.code,
            RadioButtonList1: this.loginForm.RadioButtonList1
          }
          if (valid) {
            this.loading = true
            this.$store.dispatch('Login', user).then(() => {
              this.loading = false
              this.$router.push({ path: '/' })
            }).catch(() => {
              this.codeUrl = `${this.apiBase}/kaptcha/create?timestamp=${Date.now()}`
              this.loading = false
            })
          } else {
            this.codeUrl = `${this.apiBase}/kaptcha/create?timestamp=${Date.now()}`
            console.log('error submit!!')
            return false
          }
        })
      }
    }
  }
</script>

<style rel="stylesheet/scss" lang="scss">
  .login {
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    background-image: url('../assets/images/login_bg.png');
    background-size: cover;
    background-position: center;
    padding: 24px;

    &::before {
      content: "";
      position: absolute;
      inset: 0;
      background:
        radial-gradient(1200px 600px at 20% 20%, rgba(24, 144, 255, 0.55), transparent 55%),
        radial-gradient(900px 520px at 80% 30%, rgba(16, 185, 129, 0.45), transparent 60%),
        linear-gradient(135deg, rgba(15, 23, 42, 0.25), rgba(15, 23, 42, 0.35));
      pointer-events: none;
    }
  }

  .title {
    margin: 0 auto 30px auto;
    text-align: center;
    color: #0f172a;
    font-size: 22px;
    font-weight: 800;
    letter-spacing: 0.5px;
  }

  .subtitle {
    text-align: center;
    color: rgba(15, 23, 42, 0.65);
    margin: -18px auto 22px auto;
    font-size: 13px;
    letter-spacing: 0.6px;
  }

  .login-form {
    position: relative;
    z-index: 1;
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.88);
    width: 420px;
    padding: 30px 30px 14px 30px;
    border: 1px solid rgba(255, 255, 255, 0.35);
    box-shadow: var(--shadow-md);
    backdrop-filter: blur(10px);

    .el-input {
      height: 42px;

      input {
        height: 42px;
      }
    }

    .input-icon {
      height: 43px;
      width: 14px;
      margin-left: 2px;
    }
  }

  .login-tip {
    font-size: 13px;
    text-align: center;
    color: #bfbfbf;
  }

  .login-code {
    width: 33%;
    display: inline-block;
    height: 42px;
    float: right;

    img {
      cursor: pointer;
      vertical-align: middle;
      height: 42px;
      width: 100%;
      border-radius: 10px;
      border: 1px solid var(--border);
      background: rgba(255, 255, 255, 0.9);
    }
  }

  #el-login-footer {
    z-index: 2;
    color: rgba(255, 255, 255, 0.88);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.25);
  }
</style>
