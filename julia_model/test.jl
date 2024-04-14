using CSV
using DataFrames
using Plots

# 读取CSV数据文件
data = CSV.read("input_data.csv", DataFrame)

# 提取计划时间数据并转换为float类型
plan_time = convert(Array{Float64}, data[:, :计划时间])

# 划分前32个和后32个数据点
data1 = plan_time[1:32]
data2 = plan_time[33:64]

# OptimalPlus模型定义
struct OptimalPlus{H,T} <: AbstractModel{T}
    cost::Float64
    β_select::T
    β_term::T
    β_expand::T
    ε::T
end

OptimalPlus(args...) = OptimalPlus{:Default}(args...)

# 默认参数空间
default_space(::Type{OptimalPlus{:Default}}) = Space(
    :cost => COSTS,
    :β_select => (0, 0, 50, Inf),
    :β_term => (0, 0, 20, Inf),
    :β_expand => 0.,
    :ε => (.01, .1, .5, 1.)
)

# 提取数据特征
function features(::Type{OptimalPlus{H,T}}, data::Vector{Float64}) where {H,T}
    (
        data = data
    )
end
    
# 动作分布
function action_dist(model::OptimalPlus, φ::NamedTuple) 
    # 在此简化版本中,我们直接使用输入数据的均值作为虚拟的动作
    mean(φ.data)
end

# 定义cost,β等参数
COSTS = [0.5, 1.0, 2.0] 
β_select = (0, 0, 30, Inf)
β_term = (0, 0, 10, Inf)
β_expand = 0.
ε = (0.01, 0.1, 0.5)

# 分别对两类数据进行拟合
model1 = OptimalPlus(COSTS[2], β_select[3], β_term[3], β_expand, ε[2])
a1 = action_dist(model1, features(OptimalPlus, data1))

model2 = OptimalPlus(COSTS[2], β_select[4], β_term[2], β_expand, ε[3]) 
a2 = action_dist(model2, features(OptimalPlus, data2))

# 绘制data1拟合曲线
p1 = plot(data1, label="Data 1")
hline!([a1], label="Optimal Action Data 1", line=(4, :dash, 0.6, [:green]))
title!("Data 1 Fitting")

# 绘制data2拟合曲线  
p2 = plot(data2, label="Data 2") 
hline!([a2], label="Optimal Action Data 2", line=(4, :dash, 0.6, [:red]))
title!("Data 2 Fitting")

# 保存图像文件
savefig(p1, "data1_fit.png")
savefig(p2, "data2_fit.png")