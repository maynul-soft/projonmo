class VipRewardModel {
  final int level;
  final String title;
  final double dailyReward;
  final String icon;

  VipRewardModel({
    required this.level,
    required this.title,
    required this.dailyReward,
    this.icon = '',
  });

  factory VipRewardModel.fromJson(Map<String, dynamic> json) {
    return VipRewardModel(
      level: json['level'] ?? 1,
      title: json['title']?.toString() ?? 'VIP 1',
      dailyReward: (json['daily_reward'] ?? json['dailyReward'] as num?)?.toDouble() ?? 2.0,
      icon: json['icon']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'daily_reward': dailyReward,
      'icon': icon,
    };
  }
}
