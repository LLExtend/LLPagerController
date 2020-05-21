Pod::Spec.new do |spec|

    # 库名称
    spec.name         = "LLPagerController"

    # 版本号
    spec.version      = "1.0.0"

    # 简短描述
    spec.summary      = "仿今日头条标题pageController"

    # 开源库地址
    spec.homepage     = "https://github.com/LLExtend/LLPagerController"

    # 开源协议
    spec.license      = { :type => "MIT", :file => "LICENSE" }

    # 开源库作者
    spec.author       = { "zhaoyulong" => "1432039807@qq.com" }

    # build的平台
    spec.platform     = :ios, "8.0"

    # 开源库Github路径
    spec.source       = { :git => "https://github.com/LLExtend/LLPagerController.git", :tag => "#{spec.version}" }

    # 开源库资源文件
    spec.source_files  = "LLPagerController/Classes/*.{h,m}"

end
