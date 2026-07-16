import '../dtos/translation_dto.dart';
import '../dtos/dot_payload_dto.dart';

abstract class ITranslationService {
  Future<TranslationResponseDto> translateText(
    String text,
    DotPayloadDto context,
  );
}
