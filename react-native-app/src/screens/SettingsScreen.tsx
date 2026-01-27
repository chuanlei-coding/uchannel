import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Switch,
  StatusBar,
} from 'react-native';
import {Colors} from '../utils/colors';
import {useNavigation} from '@react-navigation/native';
import type {NativeStackNavigationProp} from '@react-navigation/native-stack';
import type {RootStackParamList} from '../navigation/AppNavigator';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface SettingItemProps {
  icon: string;
  title: string;
  value?: string;
  showArrow?: boolean;
  isToggle?: boolean;
  toggleValue?: boolean;
  onToggle?: (value: boolean) => void;
  isDanger?: boolean;
  onPress?: () => void;
}

const SettingItem: React.FC<SettingItemProps> = ({
  icon,
  title,
  value,
  showArrow = true,
  isToggle = false,
  toggleValue = false,
  onToggle,
  isDanger = false,
  onPress,
}) => {
  return (
    <TouchableOpacity
      style={styles.settingItem}
      onPress={onPress}
      activeOpacity={0.7}>
      <Text style={[styles.settingIcon, isDanger && styles.dangerIcon]}>
        {icon}
      </Text>
      <Text style={[styles.settingTitle, isDanger && styles.dangerText]}>
        {title}
      </Text>
      {isToggle ? (
        <Switch
          value={toggleValue}
          onValueChange={onToggle}
          trackColor={{false: Colors.textWhite20, true: '#40df20'}}
          thumbColor="#ffffff"
        />
      ) : (
        <>
          {value && <Text style={styles.settingValue}>{value}</Text>}
          {showArrow && <Text style={styles.arrowIcon}>›</Text>}
        </>
      )}
    </TouchableOpacity>
  );
};

const SettingsScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const [darkMode, setDarkMode] = useState(true);

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#142111" />

      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}>
          <Text style={styles.backIcon}>‹</Text>
          <Text style={styles.backText}>返回</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>个性化设置</Text>
        <View style={styles.headerPlaceholder} />
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.content}>
        {/* Profile Section */}
        <View style={styles.profileSection}>
          <View style={styles.avatarContainer}>
            <View style={styles.avatarOuter}>
              <View style={styles.avatarInner}>
                <Text style={styles.avatarText}>V</Text>
              </View>
            </View>
            <View style={styles.editBadge}>
              <Text style={styles.editIcon}>✏️</Text>
            </View>
          </View>
          <Text style={styles.userName}>林之境</Text>
          <Text style={styles.userSubtitle}>VITA PREMIUM EXPLORER</Text>
        </View>

        {/* Visual Style Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>视觉风格</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              icon="🌙"
              title="暗色模式"
              isToggle
              toggleValue={darkMode}
              onToggle={setDarkMode}
              showArrow={false}
            />
            <SettingItem
              icon="🎨"
              title="主题配色"
              value="Sage & Slate"
            />
            <SettingItem icon="🔤" title="字体偏好" />
          </View>
        </View>

        {/* Smart Preferences Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>智能偏好</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              icon="✨"
              title="AI 助手灵敏度"
              value="沉浸式"
            />
            <SettingItem
              icon="🔔"
              title="通知频率"
              value="仅重要事项"
            />
          </View>
        </View>

        {/* Account & Data Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>账号与数据</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              icon="☁️"
              title="云同步状态"
              value="已更新"
            />
            <SettingItem
              icon="🚪"
              title="退出登录"
              showArrow={false}
              isDanger
            />
          </View>
        </View>

        {/* Footer Quote */}
        <View style={styles.footer}>
          <Text style={styles.footerQuote}>"在微小中，见终生"</Text>
          <View style={styles.dots}>
            <View style={styles.dot} />
            <View style={styles.dot} />
            <View style={styles.dot} />
          </View>
        </View>
      </ScrollView>

      {/* Bottom Navigation */}
      <View style={styles.bottomNav}>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Schedule')}>
          <Text style={styles.navIcon}>📅</Text>
          <Text style={styles.navText}>日程</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Main')}>
          <Text style={styles.navIcon}>🤖</Text>
          <Text style={styles.navText}>AI 助手</Text>
        </TouchableOpacity>
        <View style={styles.navItem}>
          <Text style={styles.navIconActive}>⚙️</Text>
          <Text style={styles.navTextActive}>设置</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#142111',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: 'rgba(20,33,17,0.8)',
  },
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  backIcon: {
    fontSize: 28,
    color: Colors.brandSage,
    marginRight: 4,
  },
  backText: {
    fontSize: 17,
    color: Colors.brandSage,
  },
  headerTitle: {
    fontSize: 17,
    fontWeight: '500',
    color: Colors.onSurface,
  },
  headerPlaceholder: {
    width: 60,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingHorizontal: 16,
    paddingBottom: 100,
  },
  profileSection: {
    alignItems: 'center',
    marginTop: 24,
    marginBottom: 40,
  },
  avatarContainer: {
    position: 'relative',
    marginBottom: 16,
  },
  avatarOuter: {
    width: 96,
    height: 96,
    borderRadius: 48,
    borderWidth: 2,
    borderColor: 'rgba(157,198,149,0.3)',
    padding: 4,
    backgroundColor: 'rgba(44,52,48,0.5)',
  },
  avatarInner: {
    flex: 1,
    borderRadius: 44,
    backgroundColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 36,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#142111',
  },
  editBadge: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: '#40df20',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 4,
  },
  editIcon: {
    fontSize: 12,
  },
  userName: {
    fontSize: 26,
    fontStyle: 'italic',
    color: Colors.onSurface,
    marginBottom: 4,
  },
  userSubtitle: {
    fontSize: 11,
    letterSpacing: 3,
    color: 'rgba(157,198,149,0.6)',
    textTransform: 'uppercase',
  },
  section: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 11,
    fontWeight: '500',
    color: 'rgba(157,198,149,0.4)',
    textTransform: 'uppercase',
    letterSpacing: 2,
    marginBottom: 8,
    paddingHorizontal: 16,
  },
  sectionContent: {
    backgroundColor: 'rgba(26,36,27,0.5)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: Colors.textWhite05,
    overflow: 'hidden',
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.textWhite05,
  },
  settingIcon: {
    fontSize: 20,
    marginRight: 16,
  },
  dangerIcon: {
    opacity: 1,
  },
  settingTitle: {
    flex: 1,
    fontSize: 17,
    color: Colors.onSurface,
  },
  dangerText: {
    color: '#f87171',
  },
  settingValue: {
    fontSize: 15,
    fontStyle: 'italic',
    color: 'rgba(157,198,149,0.6)',
    marginRight: 8,
  },
  arrowIcon: {
    fontSize: 24,
    color: Colors.textWhite20,
  },
  footer: {
    alignItems: 'center',
    marginTop: 48,
    marginBottom: 32,
  },
  footerQuote: {
    fontSize: 14,
    fontStyle: 'italic',
    color: 'rgba(157,198,149,0.4)',
    letterSpacing: 1,
  },
  dots: {
    flexDirection: 'row',
    marginTop: 16,
    gap: 8,
  },
  dot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgba(157,198,149,0.2)',
  },
  bottomNav: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 80,
    backgroundColor: 'rgba(20,33,17,0.8)',
    borderTopWidth: 1,
    borderTopColor: Colors.textWhite05,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingHorizontal: 24,
  },
  navItem: {
    alignItems: 'center',
  },
  navIcon: {
    fontSize: 24,
    opacity: 0.4,
  },
  navIconActive: {
    fontSize: 24,
  },
  navText: {
    fontSize: 10,
    color: 'rgba(157,198,149,0.4)',
    marginTop: 4,
  },
  navTextActive: {
    fontSize: 10,
    color: Colors.brandSage,
    marginTop: 4,
  },
});

export default SettingsScreen;
