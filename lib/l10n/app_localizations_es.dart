// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appNameWordmark => 'BREWDESK';

  @override
  String get brandedLoadingLabel => 'Cargando BrewDesk';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get tierGreat => 'excelente';

  @override
  String get tierGood => 'bueno';

  @override
  String get tierMixed => 'mixto';

  @override
  String get tierWeak => 'débil';

  @override
  String get anyOption => 'Cualquiera';

  @override
  String dotJoin(String a, String b) {
    return '$a · $b';
  }

  @override
  String get filtersTooltip => 'Filtros';

  @override
  String get filtersLaptopFriendly => 'Apto para portátiles';

  @override
  String get filtersWifiTitle => 'Wi-Fi';

  @override
  String get filtersWifiOk => 'Aceptable';

  @override
  String get filtersWifiFast => 'Rápido';

  @override
  String get filtersOutletsTitle => 'Enchufes';

  @override
  String get filtersOutletsSome => 'Algunos';

  @override
  String get filtersOutletsPlenty => 'Muchos';

  @override
  String get filtersVenueTypeTitle => 'Tipo de lugar';

  @override
  String get filtersVenueTypeCafe => 'Café';

  @override
  String get filtersVenueTypeLibrary => 'Biblioteca';

  @override
  String get filtersVenueTypePark => 'Parque';

  @override
  String filtersResetCount(int count) {
    return 'Restablecer $count filtros';
  }

  @override
  String get whatNumbersMean => 'Qué significan los números';

  @override
  String get workFitCaptionLabel => 'AJUSTE LABORAL';

  @override
  String get discoveryUseMyLocationTooltip => 'Usar mi ubicación';

  @override
  String get discoverySearchHint => 'Buscar lugares para trabajar';

  @override
  String discoveryVisibleOfTotal(int visible, int total) {
    return '$visible de $total lugares';
  }

  @override
  String get discoveryBaselineBanner =>
      'Base OSM · los detalles aún se están investigando';

  @override
  String get discoveryEmptyView => 'No hay lugares en esta vista.';

  @override
  String get discoveryClearFilters => 'Quitar filtros';

  @override
  String get discoveryScoresShowWorkFit =>
      'Las puntuaciones muestran el ajuste laboral';

  @override
  String discoveryShelfSpotsInView(int count) {
    return '$count lugares en esta vista';
  }

  @override
  String get discoveryDragForMapHint => 'Arrastra para ver el mapa';

  @override
  String get discoveryTryAgain => 'Reintentar';

  @override
  String get discoveryErrorOffline =>
      'Estás sin conexión. Lo intentaremos de nuevo cuando vuelvas a estar en línea.';

  @override
  String get discoveryErrorGeneric =>
      'No pudimos conectar con el servicio de lugares. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get methodologyTitle => 'Cómo funciona Work Fit';

  @override
  String get methodologyWhatTitle => 'Qué medimos';

  @override
  String get methodologyWhatBody =>
      'Cinco atributos por lugar: política de portátiles, asientos, Wi-Fi, enchufes y ruido — más asientos al aire libre como extra. Cada dato proviene de investigación web con IA, datos curados o una visita al local.';

  @override
  String get methodologyWeightsTitle => 'Cómo se pondera la puntuación';

  @override
  String get methodologyWeightsBody =>
      'La política de portátiles domina (35%), luego asientos (25%), Wi-Fi (15%), enchufes (15%) y ruido (10%); los asientos al aire libre suman hasta +5. El Wi-Fi más rápido del mundo no vale nada donde prohíben portátiles. Por encima de aproximadamente 25 Mbps, más velocidad ya no importa: solo el Wi-Fi realmente lento penaliza fuerte.';

  @override
  String get methodologyProvenanceTitle =>
      'Por qué cada dato muestra su fuente';

  @override
  String get methodologyProvenanceBody =>
      'Un dato mueve la puntuación en proporción a cuánto lo creemos; el resto se ancla a un valor neutro. Una estimación sin verificar apenas mueve el ranking. Por eso cada dato muestra fuente, confianza y fecha — el sello solo aparece cuando una persona respalda el dato.';

  @override
  String get methodologyDecayTitle => 'Lo reciente vale más';

  @override
  String get methodologyDecayBody =>
      'La confianza se reduce a la mitad cada 90 días. Una observación de hace seis meses persuade cuatro veces menos que una fresca — así el conjunto de datos no se pudre en ficción confiada.';

  @override
  String get methodologyUnknownsTitle => 'Incógnitas honestas';

  @override
  String get methodologyUnknownsBody =>
      '\"Desconocido\" es un valor de primera clase: nunca adivinamos. Varias observaciones del mismo atributo se combinan por su mediana y la corroboración aumenta la confianza — con tope en 95%. Nunca afirmamos certeza.';

  @override
  String get methodologyDataOriginsTitle => 'De dónde vienen los datos';

  @override
  String get methodologyOriginCuratedLabel => 'Selección editorial';

  @override
  String get methodologyOriginCuratedBody =>
      'Introducido o verificado por una persona.';

  @override
  String get methodologyOriginOsmLabel => 'Base OSM';

  @override
  String get methodologyOriginOsmBody =>
      'Un listado real de OpenStreetMap con datos de aptitud para trabajar intencionalmente superficiales, aún sin investigar a fondo.';

  @override
  String get methodologyOriginAgentLabel => 'Investigado por IA';

  @override
  String get methodologyOriginAgentBody =>
      'Encontrado mediante investigación web con IA y etiquetado como estimación.';

  @override
  String get onboardingPage1Eyebrow => 'TRABAJA SIN ADIVINAR';

  @override
  String get onboardingPage1Title =>
      'Tu próximo escritorio podría servir espresso.';

  @override
  String get onboardingPage1Body =>
      'Encuentra lugares cercanos con buen Wi-Fi, enchufes y espacio para abrir el portátil.';

  @override
  String get onboardingPage2Eyebrow => 'LAS SEÑALES QUE IMPORTAN';

  @override
  String get onboardingPage2Title => 'Decide antes de pedir.';

  @override
  String get onboardingPage2Body =>
      'Compara ruido, Wi-Fi, enchufes y política de portátiles sin revisar cientos de opiniones.';

  @override
  String get onboardingPage3Eyebrow => 'HONESTO POR DISEÑO';

  @override
  String get onboardingPage3Title => 'Cada puntuación muestra su evidencia.';

  @override
  String get onboardingPage3Body =>
      'Los datos medidos van primero. Las estimaciones se identifican. Las fuentes y fechas muestran cuánto confiar.';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingFindMyWorkSpot => 'Encontrar mi lugar de trabajo';

  @override
  String onboardingPageIndicator(int page, int total) {
    return '0$page / 0$total';
  }

  @override
  String get locationIntroTitle => 'Empieza donde estás.';

  @override
  String get locationIntroBody =>
      'Tu ubicación encuentra lugares cercanos. Nunca se incluye en un informe público.';

  @override
  String get useMyLocation => 'Usar mi ubicación';

  @override
  String get useUnionSquareInstead => 'Usar Union Square';

  @override
  String get profileTitle => 'Tú';

  @override
  String get profileHeroTitle => 'Tu ciudad es tu oficina.';

  @override
  String get profileHeroBody =>
      'BrewDesk investiga Wi-Fi, asientos, enchufes, ruido y política de portátiles para que elijas un lugar con confianza.';

  @override
  String get profileAccountlessTitle => 'Sin cuenta, por diseño';

  @override
  String get profileAccountlessBody =>
      'Tus lugares guardados se quedan en este dispositivo. La ubicación solo se usa para encontrar lugares cercanos.';

  @override
  String get profileTransparentTitle => 'Investigación transparente';

  @override
  String get profileTransparentBody =>
      'Cada dato de aptitud para trabajar indica su fuente. Las estimaciones se etiquetan en lugar de presentarse como verificadas.';

  @override
  String get profileMoreThanCafesTitle => 'Pensado para más que cafeterías';

  @override
  String get profileMoreThanCafesBody =>
      'Bibliotecas, parques, centros comerciales y otros lugares prácticos para trabajar también tienen su lugar aquí.';

  @override
  String get profileHowScoringWorks => 'Cómo funciona la puntuación';

  @override
  String get profileShareApp => 'Compartir la app';

  @override
  String get profileAboutTitle => 'Acerca de';

  @override
  String get profileAboutSectionTitle => 'Acerca de';

  @override
  String get profileSupport => 'Soporte';

  @override
  String get profilePrivacyPolicy => 'Política de privacidad';

  @override
  String get profileTermsOfUse => 'Términos de uso';

  @override
  String get profileOpenSourceLicenses => 'Licencias de código abierto';

  @override
  String get profileVersionLabel => 'Versión';

  @override
  String get navSpots => 'Lugares';

  @override
  String get navSaved => 'Guardados';

  @override
  String get navYou => 'Tú';

  @override
  String get savedTitle => 'Guardados';

  @override
  String get savedImportTooltip => 'Importar desde Google Takeout';

  @override
  String get savedImportAction => 'Importar';

  @override
  String get savedFileReadError => 'No se pudo leer ese archivo.';

  @override
  String get savedLoadError =>
      'No se pudieron cargar tus lugares guardados. Desliza para reintentar.';

  @override
  String get savedEmptyTitle => 'Guarda tu próximo lugar de trabajo';

  @override
  String get savedEmptyBody =>
      'Los marcadores se quedan en este dispositivo. No se necesita cuenta.';

  @override
  String get savedBrowseNearby => 'Ver cercanos';

  @override
  String get savedFailedRowMessage => 'No se pudo cargar este lugar guardado.';

  @override
  String get savedRemove => 'Quitar';

  @override
  String takeoutResultSummary(int matched, int unmatched) {
    return '$matched coincidencias · $unmatched aún no en BrewDesk';
  }

  @override
  String get takeoutConfirmHint =>
      'Los lugares coincidentes se guardan en BrewDesk al confirmar.';

  @override
  String get takeoutNotInBrewDeskYet => 'Aún no está en BrewDesk';

  @override
  String get venueDetailWorkabilityTitle => 'Aptitud para trabajar';

  @override
  String get venueDetailWhatWeKnowTitle => 'Lo que sabemos';

  @override
  String get venueDetailClaimLaptopPolicy => 'Política de portátiles';

  @override
  String get venueDetailClaimNoise => 'Ruido';

  @override
  String get venueDetailClaimSeating => 'Asientos';

  @override
  String get venueDetailOsmDescription =>
      'Este es un listado real de OpenStreetMap. Los detalles de aptitud para trabajar aún no se han investigado a fondo.';

  @override
  String get venueDetailResearchedDescription =>
      'Este lugar combina investigación de fuentes públicas con procedencia transparente en cada dato.';

  @override
  String venueDetailUpdated(String date) {
    return 'Actualizado $date';
  }

  @override
  String get venueDetailDirections => 'Cómo llegar';

  @override
  String get venueDetailRemoveFromSaved => 'Quitar de guardados';

  @override
  String get venueDetailSaveSpot => 'Guardar lugar';

  @override
  String get venueDetailShare => 'Compartir';

  @override
  String venueCardProvenance(String date, String source) {
    return 'Actualizado $date · $source';
  }
}
