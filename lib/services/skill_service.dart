import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_model.dart';

class SkillService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get skills by employee ID
  static Future<List<SkillModel>> getSkillsByEmployeeId(String employeeId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('skills')
          .where('employee_id', isEqualTo: employeeId)
          .get();
      
      final skills = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SkillModel.fromJson({...data, 'id': doc.id});
      }).toList();
      
      // Sort skills by name locally to avoid composite index requirement
      skills.sort((a, b) => a.skillName.compareTo(b.skillName));
      
      return skills;
    } catch (e) {
      throw Exception('Failed to load employee skills: $e');
    }
  }

  // Create new skill
  static Future<bool> createSkill(SkillModel skill) async {
    try {
      final skillData = skill.toJson();
      skillData['created_at'] = FieldValue.serverTimestamp();
      skillData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('skills').add(skillData);
      return true;
    } catch (e) {
      throw Exception('Failed to create skill: $e');
    }
  }

  // Update skill
  static Future<bool> updateSkill(SkillModel skill) async {
    try {
      final skillData = skill.toJson();
      skillData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('skills')
          .doc(skill.id)
          .update(skillData);

      return true;
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  // Delete skill
  static Future<bool> deleteSkill(String skillId) async {
    try {
      await _firestore.collection('skills').doc(skillId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  // Get skill by ID
  static Future<SkillModel?> getSkillById(String skillId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('skills')
          .doc(skillId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      final data = doc.data() as Map<String, dynamic>;
      return SkillModel.fromJson({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to load skill: $e');
    }
  }

  // Check if skill name already exists for employee
  static Future<bool> skillExists(String employeeId, String skillName, {String? excludeId}) async {
    try {
      // First get all skills for the employee
      final QuerySnapshot snapshot = await _firestore
          .collection('skills')
          .where('employee_id', isEqualTo: employeeId)
          .get();
      
      // Filter locally to avoid complex composite indexes
      final matchingSkills = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final skillNameFromDoc = data['skill_name'] as String;
        final docId = doc.id;
        
        // Check if skill name matches
        if (skillNameFromDoc.toLowerCase() != skillName.toLowerCase()) {
          return false;
        }
        
        // If excludeId is provided, exclude that document
        if (excludeId != null && docId == excludeId) {
          return false;
        }
        
        return true;
      }).toList();
      
      return matchingSkills.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check skill existence: $e');
    }
  }

  // Get skill statistics for employee
  static Future<Map<String, dynamic>> getSkillStatistics(String employeeId) async {
    try {
      final skills = await getSkillsByEmployeeId(employeeId);
      
      int totalSkills = skills.length;
      double averageProficiency = skills.isEmpty 
          ? 0.0 
          : skills.map((s) => s.proficiencyLevel).reduce((a, b) => a + b) / skills.length;
      
      Map<int, int> proficiencyDistribution = {};
      for (int i = 1; i <= 5; i++) {
        proficiencyDistribution[i] = skills.where((s) => s.proficiencyLevel == i).length;
      }
      
      return {
        'totalSkills': totalSkills,
        'averageProficiency': averageProficiency,
        'proficiencyDistribution': proficiencyDistribution,
      };
    } catch (e) {
      throw Exception('Failed to get skill statistics: $e');
    }
  }
} 