#!/usr/bin/env python3
"""
自动化系统功能测试脚本
遍历所有路由，记录所有错误
"""
import json
import urllib.request
import time
import re

CDP_HOST = "localhost:9222"
errors_found = []

def http_get(url):
    try:
        with urllib.request.urlopen(url, timeout=5) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        return None

def get_page_info():
    pages = http_get(f"http://{CDP_HOST}/json")
    if not pages:
        return None
    target = [p for p in pages if p['type'] == 'page' and 'localhost:8081' in p['url']]
    return target[0] if target else None

def monitor_errors(ws_url, duration=60):
    """持续监控错误"""
    try:
        import websocket
    except ImportError:
        print("需要 websocket-client")
        return []
    
    ws = websocket.create_connection(ws_url)
    
    # 启用控制台和异常
    ws.send(json.dumps({"id": 1, "method": "Runtime.enable"}))
    ws.recv()
    ws.send(json.dumps({"id": 2, "method": "Runtime.exceptionThrown"}))
    
    print(f"📡 开始监控 {duration} 秒...")
    print("请在浏览器中依次点击所有侧边栏功能...")
    print()
    
    start_time = time.time()
    errors = []
    
    while time.time() - start_time < duration:
        try:
            ws.settimeout(1)
            msg = json.loads(ws.recv())
            
            # 捕获错误
            if msg.get('method') == 'Runtime.consoleAPICalled':
                params = msg['params']
                msg_type = params.get('type')
                if msg_type in ['error', 'warning']:
                    args = params.get('args', [])
                    if args:
                        value = args[0].get('value', args[0].get('description', ''))
                        errors.append({
                            'type': msg_type,
                            'message': value,
                            'timestamp': time.time()
                        })
                        
                        # 实时输出
                        if 'Cannot find module' in str(value):
                            print(f"❌ 发现缺失模块: {value}")
                        elif msg_type == 'error':
                            print(f"⚠️  {msg_type.upper()}: {value[:100]}")
                            
        except websocket.WebSocketTimeoutException:
            continue
        except Exception as e:
            break
    
    ws.close()
    return errors

def analyze_errors(errors):
    """分析错误，提取缺失的模块"""
    missing_modules = set()
    other_errors = []
    
    for error in errors:
        msg = str(error.get('message', ''))
        
        # 提取缺失模块路径
        match = re.search(r"Cannot find module ['\"](.+?)['\"]", msg)
        if match:
            module_path = match.group(1)
            missing_modules.add(module_path)
        elif error['type'] == 'error':
            other_errors.append(msg)
    
    return list(missing_modules), other_errors

def main():
    print("=" * 70)
    print("🔍 JwSystem 自动化功能测试")
    print("=" * 70)
    
    page = get_page_info()
    if not page:
        print("❌ 未找到页面")
        return 1
    
    print(f"\n✅ 页面: {page['title']}")
    print(f"🔗 URL: {page['url']}")
    print()
    
    # 监控60秒
    errors = monitor_errors(page['webSocketDebuggerUrl'], duration=60)
    
    print("\n" + "=" * 70)
    print(f"📊 测试完成，共捕获 {len(errors)} 条错误/警告")
    print("=" * 70)
    
    # 分析错误
    missing_modules, other_errors = analyze_errors(errors)
    
    if missing_modules:
        print(f"\n❌ 发现 {len(missing_modules)} 个缺失模块:")
        for i, module in enumerate(sorted(missing_modules), 1):
            print(f"  {i}. {module}")
    
    if other_errors:
        print(f"\n⚠️  其他错误 ({len(other_errors)} 条):")
        for i, err in enumerate(other_errors[:5], 1):
            print(f"  {i}. {err[:100]}...")
    
    # 生成报告
    with open('/tmp/jwsystem_test_report.json', 'w', encoding='utf-8') as f:
        json.dump({
            'total_errors': len(errors),
            'missing_modules': missing_modules,
            'other_errors': other_errors[:10],
            'timestamp': time.time()
        }, f, indent=2, ensure_ascii=False)
    
    print(f"\n📝 详细报告已保存: /tmp/jwsystem_test_report.json")
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())
