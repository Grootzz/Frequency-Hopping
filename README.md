# 跳频通信系统仿真

本示例演示了跳频通信系统的整个工作流程，包括调制，跳频，解调，解调。

在本示例中，忽略同步相关的问题，包括跳频同步，帧同步，定时同步，载波同步等。

其中，调制采用MSK调制方式，解调采用复差分解调方式。

## 目录说明

未列出文件不做说明，本系统未使用。

`.code/html`  :`sim_ber.m`与`sim_analysis.m`中代码的`html`查看方式，内容与`sim_ber.m`和`sim_analysis.m`中的内容一致。双击`sim_ber.html`或`sim_main.html`即可预览代码  

**核心文件**

`.code/sim_analysis.m`  :仿真分析系统（局部参数调节分析时，可以在这个文件中完成）  
`.code/sim_ber.m`       :性能分析，通过同统计误比特率完成分析  

**核心函数**

`.code/MSKmodulator.m`          :MSK基带调制器  
`.code/phaseTraceGenerator.m`   :`CPM`信号生成器  
`.code/FHmodulator.m `          :跳频调制器  
`.code/FHdemodulator.m`         :跳频解跳器  

**工具函数（用于频域分析）**

`.code/fftshow.m`   :低通信号fft分析（功率谱）  
`.code/fftTool.m`   :低通信号fft分析（幅度谱）  










Good luck!