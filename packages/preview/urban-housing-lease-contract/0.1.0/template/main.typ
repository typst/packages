#import "@preview/urban-housing-lease-contract:0.1.0 ": *
#show: config.with(
  //合同标题
  title: "城镇房屋租赁合同",
  //合同签署日期时间
  sign-datetime: datetime.today(),
  //------------------- 房屋信息 -------------------
  house: (
    //房屋坐落地址
    location: "江西省鹰潭市余江区邓埠镇8号楼808",
    //建筑面积（平方米）
    area: 119.37,
    //室数（卧室数量）
    bedroom: 3,
    //厅数（客厅数量）
    hall: 2,
    //卫数（卫生间数量）
    bathroom: 2,
    //厨数（厨房数量）
    kitchen: 1,
    //房屋朝向
    orientation: "南北",
    //装修情况：毛坯/精装/简装/其他
    renovation: "精装",
    //装修情况详情（当选择"其他"时填写）
    renovation-detail: "",
    //是否有车库/车位：是/否
    garage: "是",
    //车库/车位位置
    garage-location: "车库/车位位置",
    //车库/车位是否一并出租：是/否
    rent-garage: "是",
    //不动产权证号
    no: "赣(2020)余江区不动产权第88888888号",
    //房屋是否设定抵押权：是/否
    mortgage: "否",
    //抵押权人（若无抵押则填"无"）
    mortgagee: "无",
    //甲方是否为房屋所有权人/购房人/使用权人/其他
    ownership: "所有权人",
    //所有权人详情（当选择"其他"时填写）
    ownership-detail: "",
    //房屋合法权属证明类型：房屋所有权证/不动产权证书/房屋买卖合同/房屋租赁合同/其他
    legal-title-certificate: "不动产权证书",
    //权属证明详情（当选择"其他"时填写）
    legal-title-certificate-detail: "",
    //房屋合法权属证明编号
    legal-title-certificate-no: "房屋合法权属证明编号",
    //其他约定事项
    other: "          ",
  ),
  //------------------- 租赁条款 -------------------
  lease: (
    //租金信息
    rent: (
      //月租金金额（元）
      monthly: 1666,
      //税费信息
      taxes-and-fees: (
        //租金是否包含税费：包含/不包含
        flag: "包含",
        //税费金额（元）
        value: 0,
      ),
      //租金支付方式：月/季度/半年/年/一次性/其他
      payment: "半年",
      //支付方式详情（当选择"其他"时填写）
      payment-detail: "",
    ),
    //租赁开始日期
    start: (year: 2025, month: 8, day: 23),
    //租赁结束日期
    end: (year: 2026, month: 8, day: 31),
    //免租期信息
    rent-free: (
      //是否有免租期：是/否
      flag: "是",
      //免租天数
      days: 7,
      //免租期开始日期
      start: (year: 2025, month: 8, day: 23),
      //免租期结束日期
      end: (year: 2026, month: 8, day: 31),
    ),
    //续租提前通知天数
    renewal: 30,
    //提前通知天数（用于优先购买权、提前收回/退租等）
    pre: 30,
    //宽限期天数（乙方逾期付款等情况下）
    delay: 7,
    //首期租金支付时间
    first-time-payment-datetime: "2025-8-23",
    //剩余每期租金支付时间
    next-time-payment-datetime: "提前7日",
    //租赁用途：居住/办公/商业/其他
    usage: "居住",
    //是否同意转租：是/否
    sublease: "是",
    //未经同意擅自转租时，甲方有权解除合同的时间：随时/六个月内/其他
    unauthorized-sublease-terminate-the-contract-period: "随时",
    //擅自转租解除合同时间详情（当选择"其他"时填写）
    unauthorized-sublease-terminate-the-contract-period-period: "",
    //车库/车位租金（元/月）
    garage: (rent: 1000),
    //押金信息
    security-deposit: (
      //押金是否计息：计息/不计息
      flag: "计息",
      //押金金额（元）
      value: 1666,
    ),
    //甲方承担的费用项目
    jia-costs: "物业费",
    //甲方承担费用详情（当选择"其他"时填写）
    jia-costs-detail: "   ",
    //乙方承担的费用项目（可多选）
    yi-costs: ("水费", "电费", "燃气费", "电视收视费", "供暖费", "网络使用费", "停车管理费", "卫生费"),
    //乙方承担费用详情（当选择"其他"时填写）
    yi-costs-detail: "   ",
    //违约责任条款
    breach: (
      //违约金标准（如：一个月租金、两个月租金等）
      penalty: "一个月租金",
      //乙方逾期支付租金超过此天数时，甲方有权收回房屋
      rent-delay-days: 7,
      //甲方是否有权自行收回房屋：是/否
      force: "是",
      //损失赔偿是否包括合同按约定期限履行的租金：是/否
      include-rent: "否",
      //其他违约责任约定
      other: "                 ",
    ),
    //装饰装修条款
    renovation: (
      //是否同意乙方装饰装修：是/否
      agree: "否",
      //租赁期间届满时装饰装修的处理方式：由乙方拆除并恢复原状/折价归甲方所有/无偿归甲方所有
      recovery: "由乙方拆除并恢复原状",
    ),
    //乙方是否有权自行维修：是/否
    maintenance: "是",
    //其他保密信息约定
    confidential: "     ",
  ),
  //------------------- 合同份数 -------------------
  agreement: (
    //份数
    counts: (
      //合同总份数（中文大写）
      all: "两",
      //甲方份数（中文大写）
      jia: "一",
      //乙方份数（中文大写）
      yi: "一",
    ),
    //其他约定事项
    other: "                       ",
  ),
  //------------------- 甲方（出租人）信息 -------------------
  jia: (
    //姓名/名称
    name: "张三",
    //证件类型：居民身份证/护照/统一社会信用代码/其他
    identification-type: "居民身份证",
    //证件类型详情（当选择"其他"时填写，如：港澳台通行证等）
    identification-type-detail: "",
    //证件号码
    identification-no: "360622199404040404",
    //住所地（身份证上的地址）
    address: "江西省鹰潭市余江区邓埠镇西畈村666号",
    //法定代表人（若为单位则填写）
    legal-person: "张大三",
    //委托代理人
    agent: "张小三",
    //联系人
    contact-person: "张三",
    //联系电话
    phone: "13812345678",
    //联系地址/邮寄地址
    postal-address: "江西省鹰潭市余江区邓埠镇西畈村777号",
    //邮政编码
    postal-code: "335200",
    //电子邮箱
    email: "zhangsan@example.com",
    //收款账户信息
    account: (
      //账户名称
      name: "张三",
      //银行账号
      number: "1234567810111213",
      //开户银行
      bank: "中国银行",
    ),
  ),
  //------------------- 乙方（承租人）信息 -------------------
  yi: (
    //姓名/名称
    name: "李四",
    //证件类型：居民身份证/护照/统一社会信用代码/其他
    identification-type: "其他",
    //证件类型详情（当选择"其他"时填写，如：港澳台通行证等）
    identification-type-detail: "港澳台通行证",
    //证件号码
    identification-no: "360622199606060606",
    //住所地（身份证上的地址）
    address: "江西省鹰潭市余江区邓埠镇西畈村888号",
    //法定代表人（若为单位则填写）
    legal-person: "李大四",
    //委托代理人
    agent: "李小四",
    //联系人
    contact-person: "李四",
    //联系电话
    phone: "13912345678",
    //联系地址/邮寄地址
    postal-address: "江西省鹰潭市余江区邓埠镇西畈村999号",
    //邮政编码
    postal-code: "335200",
    //电子邮箱
    email: "lisi@example.com",
  ),
)
