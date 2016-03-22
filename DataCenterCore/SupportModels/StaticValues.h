


/*
 Debug输入日志配置
 */
typedef enum
{
    DebugLogOff = 1,                    //不输出任何信息
    DebugLogBasicError,                 //打印基本的错误信息
    DebugLogIncludeNetWorkStatus,       //打印网络状态
    DebugLogIncludeUrl,                 //打印Url
    DebugLogIncludeProcessStatus,       //打印请求流程
    DebugLogIncludeConfigDetail,        //打印请求配置详细信息
    DebugLogIncludeData,                //打印返回的数据
    DebugLogAll,                        //输出所有信息
}DataCenterDebugLogLevel;

typedef enum
{
    kNotUseCachedData = 0,  //不使用缓存数据
    kAlwaysAskForUpdate ,   //如果有缓存，每次询问服务器是否有更新，决定是否使用缓存数据
    kAskForUpdateWhenStale, //只有当缓存过期后才询问服务器是否有更新
}kRequestCachePolicy;

typedef enum
{
    
	HttpMethodGet = 1 , //Http Get 方法
    HttpMethodPost      //Http Post 方法
}HttpMethodType;

typedef enum
{
    R_Prepare = 0,                  //准备请求
    R_Validate,                     //验证请求
    R_Start,                        //开始请求
    R_InWaitingQueue,               //在等待队列
    R_OperateOnThread,              //在线程中开始执行
    R_FindingCache,                 //正在寻找缓存数据
    R_BeginASINetwork,              //开始网络请求
    R_TransferData,                 //正在传输数据
    R_CacheData,                    //正在缓存数据
    R_HandleResult,                 //正在处理结果
    R_ParseData,                    //正在解析数据
    R_Response,                     //准备响应
    R_Finish,                       //请求结束
}RequestProcess;                    //用于描述请求过程中的各种状态

typedef enum
{
    kRequestSuccess = 0,                     //请求成功
    kRequestTimeOut = -1,                    //请求超时
    kRequestNetworkError = -2,               //无网络链接 或者链接不上
    kRequestNoData = -3,                     //服务器成功 但是没有数据
    kRequestIsCanceled = -4,                 //请求被取消
    kRequestASIError = -5,                   //ASI内部出现Error
    kRequestCacheError = -6,                 //缓存出现错误
    kRequestUnknowError = -7,                //未知错误
    kRequestValidateError = -8,
    kRequestServerSuddenlyShutDown = 200,    //正在请求时服务突然中断 此时返回的头信息HTTP STATE 仍然为200
    kRequestBadRequest = 400,
    kRequestUnauthorized = 401,
    kRequestAuthenticationError = 403,    //权限出错
    kRequestPageNotFound = 404,        //请求失败, 服务起返回404
    kRequestServerInternalError = 500,           //请求失败, 服务器返回500
    kRequestServerNotImplemented = 501,           //请求失败，服务器返回501
    kRequestUnknowHttpStateCode = 503,
    kRequestServerDataInvalid = -500,
    kRequestServerReturnError = -1000,  //服务端提示错误
    kRequestUrlBuildError = -12,        //请求url格式有误
}kReturnCode;                            //用于请求的返回值

#define K_Error_Request         -1                  //当请求出错后默认返回的请求ID
#define DEFAULT_MAX_POOL_THREAD_COUNT 10         //默认DataCenter 同时启动的线程个数
#define DEFAULT_MAX_POOL_THREAD_COUNT_3G 4       // 默认3G状态下的线程数
#define DEFAULT_MAX_POOL_THREAD_COUNT_WIFI 8    // 默认Wifi状态下的线程数
#define kDefaultPage            1             //默认请求页码
#define kDefaultSize_iPhone          @"20"            //默认每页请求的数字

#define kDictKey_Page           @"page"
#define kDictKey_PageSize       @"pageSize"
#define kDictKey_TotalPage      @"totalPage"
#define kDictKey_TotalCount     @"totalNum"

#define kReqesutCacheReturnCode       0

