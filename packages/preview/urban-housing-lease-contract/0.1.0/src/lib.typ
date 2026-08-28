#import "style.typ": *
#let info(content) = {
  underline([#content])
}
#let radio(
  options: ((key: "key1", value: "content1", checked: true), (key: "key2", value: "content2", checked: false)),
  checked: "key1",
) = {
  options
  .map(
    it => {
      [ #if it.key == checked { emoji.checkmark.box } else { emoji.square.white } #it.key #if (it.keys().contains("value") and it.value != "") { underline(it.value) } ]
    },
  )
  .join()
}

#let checkbox(options: ((key: "key1", value: "content1", checked: true), (key: "key2", value: "content2")), checked: "key1") = {
  options
  .map(
    it => {
      [ #if it.key in checked { emoji.checkmark.box } else { emoji.square.white } #it.key #if (it.keys().contains("value") and it.value != "") { underline(it.value) } ]
    },
  )
  .join()
}

#let identification(type: "", value: "") = {
  radio(
    options: ((key: "居民身份证"), (key: "护照"), (key: "统一社会信用代码"), (key: "其他", value: value)),
    checked: type,
  )
}



#let config(
  //合同签署日期时间
  title: "城镇房屋租赁合同",
  sign-datetime: datetime.today(),
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
    //车库/车位租金（元/月）（若不单独出租则可不填）
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
    //乙方是否有权自行维修：是/否（当甲方不承担维修义务时）
    maintenance: "是",
    //其他保密信息约定
    confidential: "     ",
  ),
  //合同份数信息
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
  //甲方（出租人）信息
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
  //乙方（承租人）信息
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
  body,
) = {
  show: styling
  align(center)[
    #text(zh(2), font: "FangSong", weight: "bold")[#title]
  ]
  [

    #grid(
      columns: (20%, 30%, 20%, 30%),
      inset: .6em,
      [*甲方（出租人）：*],
      grid.cell(colspan: 3)[*#info(jia.name)*],
      [证件类型：],
      grid.cell(colspan: 3)[#identification(type: jia.identification-type, value: jia.identification-type-detail)],
      [证件号码：],
      grid.cell(colspan: 3)[#info(jia.identification-no)],
      [住所地：],
      grid.cell(colspan: 3)[#info(jia.address)],
      [法定代表人：],
      grid.cell(colspan: 1)[#info(jia.legal-person)],
      [委托代理人：],
      grid.cell(colspan: 1)[#info(jia.agent)],
      [联系人：],
      grid.cell(colspan: 1)[#info(jia.contact-person)],
      [联系电话：],
      grid.cell(colspan: 1)[#info(jia.phone)],
      [联系地址：],
      grid.cell(colspan: 3)[#info(jia.postal-address)],
      [邮政编码：],
      grid.cell(colspan: 3)[#info(jia.postal-code)],
      [电子邮箱：],
      grid.cell(colspan: 3)[#info(jia.email)],
      grid.cell(colspan: 4)[],
      [*乙方（承租人）：*],
      grid.cell(colspan: 3)[*#info(yi.name)*],
      [证件类型：],
      grid.cell(colspan: 3)[#identification(type: yi.identification-type, value: yi.identification-type-detail)],
      [证件号码：],
      grid.cell(colspan: 3)[#info(yi.identification-no)],
      [住所地：],
      grid.cell(colspan: 3)[#info(yi.address)],
      [法定代表人：],
      grid.cell(colspan: 1)[#info(yi.legal-person)],
      [委托代理人：],
      grid.cell(colspan: 1)[#info(yi.agent)],
      [联系人：],
      grid.cell(colspan: 3)[#info(yi.contact-person)],
      [联系电话：],
      grid.cell(colspan: 3)[#info(yi.phone)],
      [联系地址：],
      grid.cell(colspan: 3)[#info(yi.postal-address)],
      [邮政编码：],
      grid.cell(colspan: 3)[#info(yi.postal-code)],
      [电子邮箱：],
      grid.cell(colspan: 3)[#info(yi.email)],
    )

    根据《中华人民共和国民法典》及其他相关法律法规的规定，甲、乙双方在平等、自愿的基础上，经友好协商，就乙方承租甲方房屋有关事宜达成以下协议：
    + 房屋基本状况
      + 甲方出租给乙方的房屋（以下简称该房屋）坐落于：#info(house.location)。
      + 该房屋的所有权人为，甲方为房屋的#radio(
          options: ((key: "所有权人"), (key: "购房人"), (key: "使用权人"), (key: "其他", value: house.ownership-detail)),
          checked: house.ownership,
        )。甲方持有的房屋合法权属证明为：
        #radio(options: (
          (key: "房屋所有权证"),
          (key: "不动产权证书"),
          (key: "房屋买卖合同"),
          (key: "房屋租赁合同"),
          (key: "其他", value: house.legal-title-certificate-detail),
        ), checked: house.legal-title-certificate)，
        权属证明编号：#info(house.legal-title-certificate-no)。
      + 该房屋建筑面积#info(house.area)平方米，房屋#radio(options: ((key: "是"), (key: "否")), checked: house.mortgage)设定抵押权，抵押权人为#info(house.mortgagee)。
      + 该房屋户型为：#info([#house.bedroom])室#info([#house.hall])厅#info([#house.bathroom])卫#info([#house.kitchen])厨；朝向为#info([#house.orientation])；房屋装修情况为：#radio(
          options: ((key: "毛坯"), (key: "精装"), (key: "简装"), (key: "其他", value: house.renovation-detail)),
          checked: house.renovation,
        )。该房屋的附属设施、设备、家具、电器、装修等状况（下文简称“附属设施、物品”），详见附件《#link(<fujian>)[房屋交割单]》。
      + 该房屋#radio(options: ((key: "是"), (key: "否")), checked: house.garage)有车库/车位配套，位于#info(house.garage-location)， #radio(options: ((key: "是"), (key: "否")), checked: house.rent-garage)与该房屋一并出租。

      + 其他#underline(house.other)。
    + 房屋租赁
      + 该房屋的租赁用途为：#info(lease.usage)。未经甲方同意，乙方不得变更租赁用途。

    + 转租
      + 甲方#radio(options: ((key: "是"), (key: "否")), checked: lease.sublease)同意乙方转租该房屋。
      + 经甲方同意的转租不影响本房屋租赁合同效力，因转租造成房屋损失的，乙方应当承担损失赔偿责任。
      + 乙方经甲方同意将该房屋转租给第三人，转租的租金归乙方所有，转租期限不得超过乙方剩余租赁期间，超过部分的约定对甲方不具有法律约束力。
      + 乙方未经甲方同意，擅自转租该房屋的，甲方有权在知道乙方转租后#radio(options: (
          (key: "随时"),
          (key: "六个月内"),
          (key: "其他", value: lease.unauthorized-sublease-terminate-the-contract-period-period),
        ), checked: lease.unauthorized-sublease-terminate-the-contract-period)解除合同，乙方应当承担违约责任。

    + 租赁期间
      + 该房屋租赁期自#info(lease.start.year)年#info(lease.start.month)月#info(lease.start.day)日起至#info(lease.end.year)年#info(lease.end.month)月#info(lease.end.day)日止，#radio(options: ((key: "是"), (key: "否")), checked: lease.rent-free.flag)有免租期，免租期为#info(lease.rent-free.days)日，免租期自#info(lease.rent-free.start.year)年#info(lease.rent-free.start.month)月#info(lease.rent-free.start.day)日起至#info(lease.rent-free.end.year)年#info(lease.rent-free.end.month)月#info(lease.rent-free.end.day)日止。
      + 租赁期间届满，甲方有权收回该房屋，乙方应当及时返还该房屋，乙方享有以同等条件优先承租的权利。
      + 乙方要求续租的，应当在租赁期间届满前#info(lease.renewal)天通知甲方，双方协商另行订立合同。
    + 租金
      + 该房屋月租金为#info(lease.rent.monthly)元（大写：#zhnumber-upper(lease.rent.monthly)）。税费为：#info(lease.rent.taxes-and-fees.value)，租金#radio(options: ((key: "包含"), (key: "不包含")), checked: lease.rent.taxes-and-fees.flag)税费。
      + 该房屋租金按#radio(options: (
          (key: "月"),
          (key: "季度"),
          (key: "半年"),
          (key: "年"),
          (key: "一次性"),
          (key: "其他", value: lease.rent.payment-detail),
        ), checked: lease.rent.payment)方式支付。租金具体支付期限双方可以约定如下：
        + 首期租金支付时间为：#info(lease.first-time-payment-datetime)；
        + 剩余每期租金支付时间为：#info(lease.next-time-payment-datetime)。
      + 甲方收取租金账户信息：

        户名：#info(jia.account.name)

        银行账号：#info(jia.account.number)

        开户行：#info(jia.account.bank)

      + 本合同第一条第（五）项下的车库/车位与该房屋一并出租的，月租金为#info(lease.garage.rent)元（大写：#info(zhnumber-upper(lease.garage.rent))），支付方式与该房屋租金的支付方式相同，支付时间为：#info(lease.next-time-payment-datetime)。

    + 押金
      + 为保证在租赁期间乙方能够及时足额支付租金及其他相关费用和合理使用该房屋及附属设施、物品，乙方应当在签订本合同时，向甲方支付押金#info(lease.security-deposit.value)元（大写：#info(zhnumber-upper(lease.security-deposit.value))）。
      + 甲方收到押金后应当向乙方出具押金收款凭证。
      + 本合同终止时，在乙方结清租赁期间产生的租金和其他相关费用后，甲方应当将押金（#radio(options: ((key: "计息"), (key: "不计息")), checked: lease.security-deposit.flag)）全额返还乙方。乙方未结清租赁期间产生的租金和其他相关费用的，甲方有权从押金中抵扣，抵扣后如果有剩余的，甲方应当将剩余部分返还乙方；押金不足以抵扣的，甲方有权向乙方追偿差额。
    + 其他相关费用

      + 甲方承担#checkbox(options: (
          (key: "物业费"),
          (key: "水费"),
          (key: "电费"),
          (key: "电话费"),
          (key: "电视收视费"),
          (key: "网络使用费"),
          (key: "供暖费"),
          (key: "燃气费"),
          (key: "停车管理费"),
          (key: "卫生费"),
          (key: "卫生费"),
          (key: "公共部位电费"),
          (key: "其他", value: lease.jia-costs-detail),
        ), checked: lease.jia-costs)。
      + 乙方承担#checkbox(options: (
          (key: "物业费"),
          (key: "水费"),
          (key: "电费"),
          (key: "电话费"),
          (key: "电视收视费"),
          (key: "网络使用费"),
          (key: "供暖费"),
          (key: "燃气费"),
          (key: "停车管理费"),
          (key: "卫生费"),
          (key: "公共部位电费"),
          (key: "其他", value: lease.yi-costs-detail),
        ), checked: lease.yi-costs)。
      + 甲乙双方应当及时足额缴纳己方承担的费用。
      + 甲方逾期缴纳其承担的费用，影响乙方正常使用的，乙方有权自行缴纳，并在租金中抵扣； 对甲方进行催告，甲方在催告后#info(lease.delay)天内仍不缴纳，影响乙方正常使用的，乙方有权提前解除合同并追究甲方违约责任。
      + 乙方逾期缴纳其承担的费用，甲方代为缴纳的，甲方有权从押金中抵扣。押金被抵扣的，乙方应当在#info(lease.delay)天内向甲方补足。乙方逾期未补足押金的，甲方有权解除合同并要求乙方承担违约责任。
    + 房屋交付及返还
      + 甲方应当于 #radio(options: (
          (key: "合同成立之日"),
          (key: [#lease.start.year 年#lease.start.month 月 #lease.start.day 日]),
          (key: "其他", value: lease.rent.payment-detail),
        ), checked: [#lease.start.year 年#lease.start.month 月 #lease.start.day 日])将该房屋交付给乙方。甲方迟延交付房屋达#info(lease.delay)日的，乙方有权解除合同并要求甲方承担违约责任。
      + 租赁期间届满或本合同提前终止时，乙方应当将该房屋返还甲方，并保证附属设施、物品的完整良好状态(租赁期间的自然损耗除外)。
      + 甲乙双方共同验收该房屋、在《#link(<fujian>)[房屋交割单]》签名（盖章）并移交房门钥匙，视为房屋交付或者返还完成。
      + 乙方逾期返还房屋的，乙方应当按照#info(lease.breach.penalty)的标准向甲方支付违约金，并承担逾期期间产生的与该房屋有关的各项费用，给甲方造成其他损失的，乙方应当承担赔偿责任。
    + 房屋使用
      + 乙方应当按合同约定的用途合理使用该房屋及附属设施、物品。出现毁损或者其他影响正常使用情形时，应当及时告知甲方，并采取必要措施以避免损失扩大。
      + 甲方未经乙方同意，不得擅自进入该房屋。确有必要进入的，甲方应当提前与乙方约定时间，乙方应当予以配合。
      + 甲方#radio(options: ((key: "是"), (key: "否")), checked: lease.renovation.agree)同意乙方装饰装修该房屋。如甲方同意乙方装修的，乙方装修过程中严禁破坏房屋主体、承重结构，应确保房屋安全，严格遵守国家有关住宅室内装饰装修管理规定及相关小区物业管理规定。
        + 乙方经甲方同意装饰装修的，租赁期间届满，装饰装修#radio(
            options: ((key: "由乙方拆除并恢复原状"), (key: "折价归甲方所有"), (key: "无偿归甲方所有")),
            checked: lease.renovation.recovery,
          )。甲方对乙方装饰装修和增设的物品不承担维修义务。因拆除造成该房屋毁损的，乙方应当承担恢复原状或者赔偿损失责任。
        + 乙方经甲方同意装饰装修的，因合同提前终止造成的乙方装饰装修残值损失按以下方式承担：
          + 因违约提前终止合同的，由违约方承担剩余租赁期间装饰装修残值损失；
          + 因不可归责于双方的事由提前终止合同的，剩余租赁期间的装饰装修残值损失，由双方按照公平原则协商分担。
        + 乙方未经甲方同意装饰装修的，甲方有权解除合同并要求乙方承担恢复原状或者赔偿损失等责任。

    + 房屋维修
      + 租赁期间，甲方应当保障该房屋及附属设施、物品处于正常使用的状态，并承担乙方正常使用下该房屋及附属设施、物品损坏的维修义务。乙方有权在房屋及附属设施、物品需要维修时，请求甲方在合理期限内维修。
      + 因甲方不承担房屋的维修义务,致使乙方无法正常使用房屋及附属设施、物品的，乙方#radio(options: ((key: "是"), (key: "否")), checked: lease.maintenance)有权自行维修。经甲方同意，乙方维修的，维修费用由甲方承担。
      + 甲方既不承担维修义务，也不愿意承担乙方维修所产生的费用的，乙方有权解除合同并要求甲方承担违约责任。
      + 乙方应当合理使用并爱护该房屋及附属设施、物品。乙方因保管不当或者使用不当造成该房屋及附属设施、物品毁坏的，乙方应当承担维修、更换或者赔偿损失责任。乙方拒绝的，甲方有权解除合同并要求乙方承担违约责任。
    + 优先购买权
      + 甲方出卖该房屋的，应当提前#info(lease.pre)日通知乙方。乙方享有以同等条件优先购买的权利。
    + 保密要求
      + 甲、乙双方对订立合同过程中知悉的对方的商业秘密（包括技术信息和经营信息）及双方约定的其他保密信息即#info(lease.confidential)，无论本合同是否成立，均不得泄露或者不正当地使用；任何一方泄露、不正当地使用该商业秘密或者保密信息，给对方造成损失的，应当承担赔偿责任。
    + 甲方权利和义务
      + 甲方应当保证有权出租该房屋，甲方应当向乙方出示身份证明、房屋权属证明、有权决定该房屋出租事宜的相关证明。
      + 甲方有权要求乙方出示身份证明。
      + 甲方应当保证该房屋的出租不违反法律法规的相关规定，房屋产权人或者共有人对该房屋的出租无异议，该房屋不存在查封冻结等限制情形。
      + 甲方应当保证该房屋未设立居住权，不影响乙方正常使用。在租赁期间，甲方不得就该房屋设立居住权。
      + 甲方应当及时交付该房屋并在租赁期间保持该房屋及附属设施、物品符合本合同约定用途的状态。
      + 甲方有权要求乙方按照合同约定的时间、方式及时足额交付租金、押金及其他相关费用。
      + 甲方有权在租赁期间届满或者本合同终止时，要求乙方及时返还该房屋。
      + 法律规定或者本合同约定的其他权利义务。
    + 乙方权利和义务
      + 乙方有权要求甲方出示身份证明、房屋权属证明、有权决定该房屋出租事宜的相关证明。
      + 乙方应当向甲方出示身份证明。
      + 乙方应当按合同约定的时间、方式及时足额支付租金、押金及其他费用。
      + 乙方不得在该房屋内进行违法犯罪行为或者其他违反法律法规规定的行为。
      + 乙方应当遵守物业管理相关规定、小区管理规约，不得损害相邻关系权利人的合法权益。
      + 乙方应当注意用水、用电、用气等的安全，不得在房屋内从事危及自身和他人人身和财产安全的行为。因乙方原因致使发生火灾或其他安全性事故，造成乙方或者他人人身或财产受损害的，由乙方承担相应责任。因上述行为给甲方造成损失的，乙方应当承担赔偿责任。
      + 乙方应当在租赁期间届满或者本合同终止时，按照合同约定及时返还该房屋。
      + 法律规定或者本合同约定的其他权利义务。
    + 违约责任
      + 甲方提前收回该房屋的，或者乙方提前退租的，应当提前#info(lease.pre)日书面通知对方，并经对方同意后，应当按照#info(lease.breach.penalty)的标准向对方支付违约金。
      + 甲方未按约定时间交付该房屋，应当按照#info(lease.breach.penalty)的标准承担违约责任。甲方未按约定时间返还乙方的押金、租金的，应当按照#info(lease.breach.penalty)的标准承担违约责任。
      + 乙方未按约定时间返还该房屋，应当按照#info(lease.breach.penalty)的标准承担违约责任。乙方逾期返还房屋且未支付逾期期间的租金超过#info(lease.breach.rent-delay-days)日时，甲方#radio(options: ((key: "是"), (key: "否")), checked: lease.breach.force)有权自行收回房屋并处置乙方放置在该房屋内的物品。
      + 乙方未按约定时间支付租金、押金或者费用，应当按照#info(lease.breach.penalty)的标准承担违约责任。
      + 任何一方有其他违约行为的，应当承担继续履行、采取补救措施或者赔偿损失等违约责任。
      + 损失赔偿额应当相当于因违约所造成的损失，#radio(options: ((key: "是"), (key: "否")), checked: lease.breach.include-rent)包括合同按约定期限履行的租金。损失赔偿额不得超过违约一方订立合同时预见到或者应当预见到的因违约可能造成的损失。
    + 合同变更、终止
      + 本合同经甲、乙双方协商一致可以变更。
      + 有下列情形之一的，本合同可以终止：
        + 甲、乙双方协商一致同意终止的；
        + 发生法律规定的终止事由的；
        + 该房屋被依法征收征用的；
        + 该房屋因不可抗力原因毁损、灭失，致使乙方不能正常使用的；
        + 发生法律规定或者本合同约定的解除事由，解除权人提出解除合同的；
        + 有下列情形之一，乙方提出解除合同的：
          + 该房屋被司法机关或者行政机关依法查封、扣押，致使无法按合同约定使用的；
          + 该房屋权属有争议，致使无法按合同约定使用的；
          + 该房屋具有违反法律、行政法规关于使用条件的强制性规定情形；
          + 该房屋危及乙方人身财产安全的；
        + 有下列情形之一，甲方提出解除合同的：
          + 乙方擅自改变该房屋用途或者利用该房屋从事违法违规活动的；
          + 乙方擅自变动该房屋建筑主体和承重结构的；
          + 乙方擅自改建、扩建、装饰装修该房屋或者变更该房屋的附属设施、物品，经甲方要求，在#info(lease.breach.rent-delay-days)日内未恢复原状的；
        + 其他#info(lease.breach.other)。
    + 不可抗力
      + 不可抗力是指不能预见、不能避免并不能克服的客观情况。
      + 任何一方因不可抗力的原因不能履行合同或者不能完全履行合同的，应当及时向对方通报不能履行或者不能完全履行的理由，以减轻给对方造成的损失；并应当在#info(lease.pre)日内向对方提供不可抗力发生的证明材料，以部分或者全部免除相应的违约责任。
      + 双方可以根据不可抗力的影响情况协商延期履行、部分履行、不履行合同或者解除合同。
    + 通知、送达
      + 双方保证在本合同中记载的联系电话、联系地址、电子邮箱等信息均真实有效并作为本合同履行以及法院或者仲裁机构解决本合同争议时的有效联系方式和送达地址。
      + 任何一方变更联系电话、联系地址、电子邮箱的，应当自变更之日起#info(lease.pre)日内书面通知对方，并提供变更后的信息；未及时通知的，对方按照本合同约定的联系方式和送达地址进行送达的，视为有效送达。
    + 法律适用及争议解决
      + 本合同之订立、生效、解释、变更、终止、执行与争议解决均适用中华人民共和国的法律法规。
      + 甲、乙双方因合同内容或者履行本合同发生任何争议，由双方协商解决；协商不成的，任何一方均可通过以下第 种方式解决：
        + 向 人民法院提起民事诉讼；
        + 向 仲裁委员会提请仲裁。
    + 附则
      + 本合同自甲、乙双方签名（盖章）之日起成立并生效。
      + 本合同附件为本合同不可分割的组成部分，与本合同具有同等效力。
      + 本合同部分条款的无效或者变更不影响其他条款的效力。
      + 双方有权以书面形式对本合同进行变更或者补充，变更或者补充合同与本合同具有同等效力。
      + 本合同一式#info(agreement.counts.all)份，其中甲方#info(agreement.counts.jia)份，乙方#info(agreement.counts.yi)份，具有同等效力。
    + 其他



      #info(agreement.other)



    附件：房屋交割单
    \
    \
    【以下无正文】
    \
    \
    #align(center)[
      #grid(
        columns: (25%, 25%, 25%, 25%),
        gutter: 2em,
        align: left,
        [甲方（签字/盖章）：],
        [],
        [乙方（签字/盖章）：],
        [],
        [法定代表人：],
        [],
        [法定代表人：],
        [],
        [委托代理人：],
        [],
        [委托代理人：],
        [],
        grid.cell(colspan: 2, align: center)[#sign-datetime.display("[year]年[month]月[day]日")],
        grid.cell(colspan: 2, align: center)[#sign-datetime.display("[year]年[month]月[day]日")],
      )
    ]

    #pagebreak()
    #set par(first-line-indent: 0em)
    #text(zh(3), weight: "bold")[附件<fujian>]
    #align(center)[

      #text(zh(2), weight: "bold")[房屋交割清单]
    ]
    #align(left)[
      房屋坐落：#info(house.location)

      权属证号：#info(house.no)
    ]
    #set par(first-line-indent: 2em)
    甲乙双方共同确认，本附件所约定房屋的附属设施、设备、家具、电器、装饰装修、相关物品等随同该房屋交付。

    如果租赁房屋用于办公或者其他用途，下述房屋交割单不足以涵盖双方需要交接内容的，由双方自行制作其余所涉及物品、设施等交割单，并根据交割单查验交付相关物品、设施。
    #table(
      align: center + horizon,
      columns: (20%, 15%, 15%, 15%, 15%, 20%),
      inset: .8em,
      table.cell(colspan: 6)[ 生活费用信息 ],
      [项目],
      [现底数],
      [已结至],
      [单价],
      [余额],
      [备注],
      [冷水],
      [],
      [],
      [],
      [],
      [],
      [中水],
      [],
      [],
      [],
      [],
      [],
      [热水],
      [],
      [],
      [],
      [],
      [],
      [电],
      [],
      [],
      [],
      [],
      [],
      [暖气],
      [],
      [],
      [],
      [],
      [],
      [燃气],
      [],
      [],
      [],
      [],
      [],
      [卫生费],
      [],
      [],
      [],
      [],
      [],
      [共用电费],
      [],
      [],
      [],
      [],
      [],
      [网费],
      [],
      [],
      [],
      [],
      [],
      [电视费],
      [],
      [],
      [],
      [],
      [],
      [电话费],
      [],
      [],
      [],
      [],
      [],
      [物业费],
      [],
      [],
      [],
      [],
      [],
      table.cell(colspan: 6)[ 卧室 ],
      [项目],
      [品牌],
      [数量],
      [物品所属],
      [物品状态],
      [备注],
      [床],
      [],
      [],
      [],
      [],
      [],
      [床垫],
      [],
      [],
      [],
      [],
      [],
      [床头柜],
      [],
      [],
      [],
      [],
      [],
      [书桌],
      [],
      [],
      [],
      [],
      [],
      [电脑桌],
      [],
      [],
      [],
      [],
      [],
      [空调],
      [],
      [],
      [],
      [],
      [],
      [衣柜],
      [],
      [],
      [],
      [],
      [],
      [地板],
      [],
      [],
      [],
      [],
      [],
      [窗户],
      [],
      [],
      [],
      [],
      [],
      [阳台],
      [],
      [],
      [],
      [],
      [],
      [其他],
      [],
      [],
      [],
      [],
      [],
      table.cell(colspan: 6)[ 客厅 ],
      [项目],
      [品牌],
      [数量],
      [物品所属],
      [物品状态],
      [备注],
      [电视机],
      [],
      [],
      [],
      [],
      [],
      [ 机顶盒 ],
      [],
      [],
      [],
      [],
      [],
      [光猫],
      [],
      [],
      [],
      [],
      [],
      [穿衣镜],
      [],
      [],
      [],
      [],
      [],
      [空调],
      [],
      [],
      [],
      [],
      [],
      [沙发],
      [],
      [],
      [],
      [],
      [],
      [茶几],
      [],
      [],
      [],
      [],
      [],
      [桌椅],
      [],
      [],
      [],
      [],
      [],
      [餐具],
      [],
      [],
      [],
      [],
      [],
      [鞋柜],
      [],
      [],
      [],
      [],
      [],
      [防盗门],
      [],
      [],
      [],
      [],
      [],
      [地板],
      [],
      [],
      [],
      [],
      [],
      [窗户],
      [],
      [],
      [],
      [],
      [],
      [阳台],
      [],
      [],
      [],
      [],
      [],
      [其他],
      [],
      [],
      [],
      [],
      [],
      table.cell(colspan: 6)[ 厨房 ],
      [项目],
      [品牌],
      [数量],
      [物品所属],
      [物品状态],
      [备注],
      [冰箱],
      [],
      [],
      [],
      [],
      [],
      [燃气灶],
      [],
      [],
      [],
      [],
      [],
      [抽油烟机],
      [],
      [],
      [],
      [],
      [],
      [燃气热水器],
      [],
      [],
      [],
      [],
      [],
      [微波炉],
      [],
      [],
      [],
      [],
      [],
      [地板],
      [],
      [],
      [],
      [],
      [],
      [窗户],
      [],
      [],
      [],
      [],
      [],
      [水龙头],
      [],
      [],
      [],
      [],
      [],
      [其他],
      [],
      [],
      [],
      [],
      [],
      table.cell(colspan: 6)[ 卫生间 ],
      [项目],
      [品牌],
      [数量],
      [物品所属],
      [物品状态],
      [备注],
      [马桶],
      [],
      [],
      [],
      [],
      [],
      [洗衣机],
      [],
      [],
      [],
      [],
      [],
      [浴霸],
      [],
      [],
      [],
      [],
      [],
      [热水器],
      [],
      [],
      [],
      [],
      [],
      [淋浴器],
      [],
      [],
      [],
      [],
      [],
      [地板],
      [],
      [],
      [],
      [],
      [],
      [窗户],
      [],
      [],
      [],
      [],
      [],
      [水龙头],
      [],
      [],
      [],
      [],
      [],
      [其他],
      [],
      [],
      [],
      [],
      [],
      table.cell(colspan: 6)[ 遥控器、钥匙及凭证信息 ],
      [项目],
      [品牌],
      [数量],
      [物品所属],
      [物品状态],
      [备注],
      [电视遥控器],
      [],
      [],
      [],
      [],
      [],
      [机顶盒遥控器],
      [],
      [],
      [],
      [],
      [],
      [空调遥控器],
      [],
      [],
      [],
      [],
      [],
      [电卡],
      [],
      [],
      [],
      [],
      [],
      [燃气卡],
      [],
      [],
      [],
      [],
      [],
      [防盗门钥匙],
      [],
      [],
      [],
      [],
      [],
      [其他],
      [],
      [],
      [],
      [],
      [],
      table.cell(colspan: 6)[ 其他物品 ],
      [项目],
      [品牌],
      [数量],
      [物品所属],
      [物品状态],
      [备注],
      [#sym.space],
      [],
      [],
      [],
      [],
      [],
      [#sym.space],
      [],
      [],
      [],
      [],
      [],
      [#sym.space],
      [],
      [],
      [],
      [],
      [],
      [#sym.space],
      [],
      [],
      [],
      [],
      [],
      [#sym.space],
      [],
      [],
      [],
      [],
      [],
    )
  ]

  linebreak()
  align(center)[
    #grid(
      columns: (25%, 25%, 25%, 25%),
      gutter: 2em,
      align: left,
      [甲方（签字/盖章）：],
      [],
      [乙方（签字/盖章）：],
      [],
      [法定代表人：],
      [],
      [法定代表人：],
      [],
      [委托代理人：],
      [],
      [委托代理人：],
      [],
      grid.cell(colspan: 2, align: center)[#sign-datetime.display("[year]年[month]月[day]日")],
      grid.cell(colspan: 2, align: center)[#sign-datetime.display("[year]年[month]月[day]日")],
    )
  ]
  body
}
