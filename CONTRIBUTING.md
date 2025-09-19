# Contributing to OGÜ Bilgi Sistemi

Projeye katkıda bulunmak istediğiniz için teşekkürler! 🎉

## 🚀 Katkıda Bulunma Yolları

### 1. 🐛 Bug Report (Hata Bildirimi)
- GitHub Issues'da bug report açın
- Template'i doldurun
- Reproduce adımlarını detaylandırın
- Screenshot/video ekleyin (varsa)

### 2. 💡 Feature Request (Özellik İsteği)  
- Yeni özellik fikirlerinizi paylaşın
- Use case'leri açıklayın
- Mockup/wireframe ekleyin (varsa)

### 3. 🔧 Code Contribution (Kod Katkısı)
- Fork'layın ve branch oluşturun
- Kodlayın ve test edin
- Pull request gönderin

### 4. 📚 Documentation (Dokümantasyon)
- README iyileştirmeleri
- Kod yorumları
- Wiki katkıları

## 🛠️ Development Setup

### Gereksinimler
```bash
Flutter SDK: >=3.8.1
Dart SDK: >=3.8.1
Android Studio / VS Code
Git
```

### Kurulum
```bash
# Repository'yi fork'layın ve clone'layın
git clone https://github.com/YOURUSERNAME/ogu_bilgi_sistemi.git
cd ogu_bilgi_sistemi

# Dependencies yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## 📝 Code Style Guide

### Dart/Flutter Conventions
```dart
// ✅ Good
class StudentService {
  final String _apiUrl;
  
  Future<List<Grade>> fetchGrades() async {
    // implementation
  }
}

// ❌ Bad  
class student_service {
  String api_url;
  
  fetchGrades() {
    // implementation
  }
}
```

### Naming Conventions
- **Classes**: `PascalCase` (StudentInfo)
- **Variables/Methods**: `camelCase` (studentNumber)
- **Constants**: `SCREAMING_SNAKE_CASE` (API_BASE_URL)
- **Files**: `snake_case` (student_info.dart)

### Code Organization
```
lib/
├── core/              # Shared utilities
│   ├── services/     # API, Storage services
│   └── theme/        # App theme
├── features/         # Feature modules
│   ├── auth/         # Authentication
│   ├── grades/       # Grades management
│   └── schedule/     # Schedule management
└── main.dart         # App entry point
```

## 🔄 Pull Request Process

### 1. Branch Strategy
```bash
# Feature branch
git checkout -b feature/add-gpa-calculator

# Bug fix branch  
git checkout -b fix/login-crash

# Documentation branch
git checkout -b docs/update-readme
```

### 2. Commit Messages
```bash
# ✅ Good
git commit -m "feat: add password visibility toggle to login form"
git commit -m "fix: resolve crash when opening schedule page"
git commit -m "docs: update installation instructions"

# ❌ Bad
git commit -m "fixed stuff"
git commit -m "updates"
```

### 3. PR Template
```markdown
## Açıklama
Bu PR'da ne değişti?

## Değişiklik Tipi
- [ ] Bug fix
- [ ] New feature  
- [ ] Documentation update
- [ ] Refactoring

## Test Edildi Mi?
- [ ] Android'de test edildi
- [ ] Edge case'ler kontrol edildi

## Ekran Görüntüleri
(Varsa ekleyin)
```

## 🧪 Testing Guidelines

### Unit Tests
```dart
// test/ klasöründe
void main() {
  group('GradeCalculator', () {
    test('should calculate GPA correctly', () {
      // Test implementation
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('LoginScreen should show password field', (tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
```

## 🏗️ Architecture Guidelines

### BLoC Pattern
```dart
// State
abstract class GradesState extends Equatable {}

// Event  
abstract class GradesEvent extends Equatable {}

// BLoC
class GradesBloc extends Bloc<GradesEvent, GradesState> {}
```

### Service Layer
```dart
class ApiService {
  final Dio _dio;
  
  Future<ApiResponse<T>> get<T>(String endpoint) async {
    // Implementation
  }
}
```

## 📋 Issue Labels

| Label | Açıklama |
|-------|----------|
| `bug` | Hata raporu |
| `enhancement` | Yeni özellik |
| `documentation` | Dokümantasyon |
| `good first issue` | Yeni başlayanlar için |
| `help wanted` | Yardım isteniyor |
| `priority: high` | Yüksek öncelik |

## 🎯 Development Priorities

### High Priority
- 🔐 Security improvements
- 🐛 Critical bug fixes
- 📱 Performance optimizations

### Medium Priority  
- ✨ New features
- 🎨 UI/UX improvements
- 📊 Analytics integration

### Low Priority
- 📚 Documentation updates
- 🧹 Code refactoring
- 🎭 Visual polishing

## ❓ Getting Help

### Communication Channels
- **Issues**: GitHub Issues for bugs/features
- **Discussions**: GitHub Discussions for questions
- **Email**: efeyazgi@yahoo.com for direct contact

### Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [ESOGÜ Web Portal](https://ogubs1.ogu.edu.tr)
- [Project Wiki](https://github.com/efeyazgi/ogu_bilgi_sistemi/wiki)

## 🏆 Recognition

Contributors will be:
- Added to README contributors section
- Mentioned in release notes
- Given credit in commit history
- Invited to maintainer team (for significant contributions)

## 📜 Code of Conduct

### Be Respectful
- Use welcoming and inclusive language
- Respect differing viewpoints
- Accept constructive criticism gracefully

### Be Collaborative
- Help others learn and grow
- Share knowledge and resources
- Provide constructive feedback

### Be Patient
- Remember everyone was a beginner once
- Take time to explain concepts clearly
- Be understanding of mistakes

## 🎉 Thank You!

Every contribution, no matter how small, makes this project better for ESOGÜ students. 

**Happy Coding!** 👨‍💻👩‍💻

---

*Bu rehber, projeye kaliteli katkılar sağlamak için hazırlanmıştır.*