// gemini_ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAIService {
  static const String apiKey = 'AIzaSyCp1xENJMaHGwx1l-3QNe12UFqZTAK5iCY'; // Replace with your actual API key
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  // System prompt to define the AI's behavior
  static const String systemPrompt = '''
You are AppTech Vibe's helpful AI assistant. You help users with questions about:
- Mobile app development
- Web development services
- E-commerce solutions
- IoT solutions
- Security services
- Enterprise solutions
- Pricing and packages
- Project timelines
- Technical support

Be friendly, professional, and concise. If you don't know something specific about AppTech Vibe's services, provide general helpful information and suggest contacting the support team for specific details.

Important guidelines:
1. Keep responses concise and to the point
2. Be helpful and professional
3. If asked about specific pricing or custom projects, suggest contacting the sales team
4. Provide technical advice when appropriate
5. Always maintain a positive and supportive tone
''';

  static Future<String> getAIResponse(String userMessage, {List<Map<String, String>>? conversationHistory}) async {
    try {
      // Build the conversation context
      List<Map<String, dynamic>> contents = [];
      
      // Add system prompt as first message
      contents.add({
        "role": "user",
        "parts": [{"text": systemPrompt}]
      });
      
      contents.add({
        "role": "model",
        "parts": [{"text": "I understand. I'm AppTech Vibe's AI assistant, ready to help with any questions about our services."}]
      });
      
      // Add conversation history if provided
      if (conversationHistory != null) {
        for (var message in conversationHistory) {
          contents.add({
            "role": message['role'] == 'user' ? "user" : "model",
            "parts": [{"text": message['message'] ?? ''}]
          });
        }
      }
      
      // Add current user message
      contents.add({
        "role": "user",
        "parts": [{"text": userMessage}]
      });

      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": contents,
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract the AI's response
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            return content['parts'][0]['text'] ?? 'I apologize, but I couldn\'t generate a response. Please try again.';
          }
        }
        
        return 'I apologize, but I couldn\'t understand your request. Could you please rephrase it?';
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return 'I\'m having trouble connecting to my AI service. Please try again later or contact our support team directly.';
      }
    } catch (e) {
      print('Error getting AI response: $e');
      return 'I apologize, but I\'m experiencing technical difficulties. Please try again later or contact our support team directly.';
    }
  }
  
  // Function to check if Gemini API is configured
  static bool isConfigured() {
    return apiKey != 'YOUR_GEMINI_API_KEY' && apiKey.isNotEmpty;
  }
  
  // Predefined responses for common questions when API is not configured
  static String getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! Welcome to AppTech Vibe. How can I help you today?';
    } else if (lowerMessage.contains('price') || lowerMessage.contains('cost')) {
      return 'We offer competitive pricing for all our services. For detailed pricing information, please contact our sales team or check our products section.';
    } else if (lowerMessage.contains('mobile app')) {
      return 'We specialize in mobile app development for both iOS and Android platforms. Our team can help you build native or cross-platform applications.';
    } else if (lowerMessage.contains('web')) {
      return 'Our web development services include responsive websites, web applications, and e-commerce solutions using the latest technologies.';
    } else if (lowerMessage.contains('time') || lowerMessage.contains('how long')) {
      return 'Project timelines vary based on complexity and requirements. Typically, mobile apps take 2-4 months, while web projects can range from 1-3 months.';
    } else if (lowerMessage.contains('support')) {
      return 'We provide comprehensive support for all our services. Our team is available to help you with any technical issues or questions.';
    } else {
      return 'Thank you for your message. Our support team will get back to you shortly with a detailed response.';
    }
  }
}