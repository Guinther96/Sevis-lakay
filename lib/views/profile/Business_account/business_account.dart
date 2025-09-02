import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevis_lakay/components/buttons_icons.dart';
import 'package:sevis_lakay/components/colors.dart';
import 'package:sevis_lakay/components/text_styles.dart';

import 'package:sevis_lakay/supabase_client.dart';
import 'package:sevis_lakay/views/info_tile/reviews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sevis_lakay/widget/dropdownbutton.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class BusinessAccount extends ConsumerStatefulWidget {
  BusinessAccount({super.key, required this.id});
  final String id;

  @override
  ConsumerState<BusinessAccount> createState() => _BusinessAccountState();
}

// Simple VideoPlayerWidget implementation
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        VideoProgressIndicator(_controller, allowScrubbing: true),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
        ),
      ],
    );
  }
}

class _BusinessAccountState extends ConsumerState<BusinessAccount> {
  double latitude = 0;
  double longitude = 0;
  bool isLiked = false;
  int likeCount = 0;
  List<Map<String, dynamic>> comments = [];

  List<dynamic> _reviews = []; // Ajout de la variable _reviews

  late TextEditingController nameController;
  late TextEditingController hourController;
  String _image = '';
  bool isLoading = true;
  bool hasUserReviewed = false;
  late String address;
  late String phone;
  late String email;
  late String description;
  late String opening_hour;
  late String closing_hour;
  bool isOwner = false; // ✅ savoir si c’est le propriétaire

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    hourController = TextEditingController();
    opening_hour = '';
    closing_hour = '';
    _loadData();
    _setupRealtimeListener();
    _checkIfUserHasReviewed();
  }

  void _setupRealtimeListener() {
    Supabase.instance.client
        .from('business_accounts')
        .stream(primaryKey: ['id'])
        .eq('id', widget.id)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            setState(() {
              opening_hour = data[0]['opening_hour']?.toString() ?? '';
              closing_hour = data[0]['closing_hour']?.toString() ?? '';
            });
          }
        });
  }

  Future<void> _checkIfUserHasReviewed() async {
    // Vérifier d'abord si le widget est toujours monté
    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Vérifier mounted avant setState
      if (mounted) {
        setState(() {
          hasUserReviewed = false;
        });
      }
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select()
          .eq('user_id', user.id)
          .eq('business_id', widget.id)
          .maybeSingle();

      // Vérifier mounted avant de mettre à jour l'état
      if (mounted) {
        setState(() {
          hasUserReviewed = response != null;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification de la review: $e');
      // En cas d'erreur, on pourrait définir une valeur par défaut
      if (mounted) {
        setState(() {
          hasUserReviewed = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    final user =
        Supabase.instance.client.auth.currentUser; // utilisateur actuel

    final response = await Supabase.instance.client
        .from('business_accounts')
        .select()
        .eq('id', widget.id)
        .maybeSingle();

    if (response == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Compte non trouvé')));
      Navigator.of(context).pop();
      return;
    }

    // Assign latitude and longitude after response is available
    latitude = (response['latitude'] ?? 0).toDouble();
    longitude = (response['longitude'] ?? 0).toDouble();

    nameController.text = response['name'] ?? '';
    hourController.text = response['openingHour'] ?? '';
    _image = response['photoUrl'] ?? '';
    address = response['address'] ?? '';
    phone = response['phone'] ?? '';
    email = response['email'] ?? '';
    opening_hour = response['openingHour'] ?? '';
    closing_hour = response['closingHour'] ?? '';
    isOwner = user != null && response['user_id'] == user.id;
    description = response['description'] ?? '';

    // vérifier si c’est le propriétaire
    if (user != null && response['user_id'] == user.id) {
      isOwner = true;
    } else {
      isOwner = false;
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _addToFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous devez être connecté pour ajouter aux favoris'),
          ),
        );
      });
      return;
    }

    try {
      // Vérifier si déjà en favori
      final existing = await Supabase.instance.client
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('business_id', widget.id) // ou int.parse(widget.id) selon type
          .maybeSingle();

      if (existing != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Déjà ajouté aux favoris')));
        });
        return;
      }

      // Sinon, ajouter
      await Supabase.instance.client.from('favorites').insert({
        'user_id': user.id,
        'business_id': widget.id, // ou int.parse(widget.id)
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ajouté aux favoris')));
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      });
    }
  }

  Future<void> _openMap() async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impossible d’ouvrir la carte')));
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Galerie'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Appareil photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );
    if (source == null) return;

    final image = await picker.pickImage(source: source);
    if (image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Aucune image sélectionnée.')));
      return;
    }

    final file = File(image.path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fichier introuvable')));
      return;
    }

    try {
      final fileName =
          'business_${widget.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('businessimages')
          .upload(fileName, file);
      final imageUrl = Supabase.instance.client.storage
          .from('businessimages')
          .getPublicUrl(fileName);

      await Supabase.instance.client
          .from('business_accounts')
          .update({'photoUrl': imageUrl})
          .eq('id', widget.id);

      if (!mounted) return;
      setState(() => _image = imageUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    final response = await supabase
        .from('reviews')
        .select('id, rating, comment, created_at, user_id') // ✅ on ajoute id
        .eq('business_id', widget.id)
        .order('created_at', ascending: false);

    return response;
  }

  bool _isBusinessOpen() {
    if (opening_hour.isEmpty || closing_hour.isEmpty) return false;

    try {
      final now = DateTime.now();
      final format = DateFormat("HH:mm");

      final openTime = format.parse(opening_hour);
      final closeTime = format.parse(closing_hour);

      final nowTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );
      final openDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        openTime.hour,
        openTime.minute,
      );
      final closeDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        closeTime.hour,
        closeTime.minute,
      );

      if (closeDateTime.isBefore(openDateTime)) {
        return nowTime.isAfter(openDateTime) || nowTime.isBefore(closeDateTime);
      } else {
        return nowTime.isAfter(openDateTime) && nowTime.isBefore(closeDateTime);
      }
    } catch (e) {
      debugPrint("Erreur de parsing des heures: $e");
      return false;
    }
  }

  Future<void> _updateBusinessHours(
    String newOpening,
    String newClosing,
  ) async {
    // Validation des heures
    if (!_isValidTime(newOpening) || !_isValidTime(newClosing)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format d\'heure invalide. Utilisez HH:MM')),
      );
      return;
    }

    try {
      await Supabase.instance.client
          .from('business_accounts')
          .update({
            'opening_hour': newOpening.isEmpty ? null : newOpening,
            'closing_hour': newClosing.isEmpty ? null : newClosing,
          })
          .eq('id', widget.id);

      setState(() {
        opening_hour = newOpening;
        closing_hour = newClosing;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Horaires mis à jour')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  bool _isValidTime(String time) {
    if (time.isEmpty) return true; // Permettre les valeurs vides
    final regExp = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regExp.hasMatch(time);
  }

  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final initialTime = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      if (isOpening) {
        await _updateBusinessHours(formattedTime, closing_hour);
      } else {
        await _updateBusinessHours(opening_hour, formattedTime);
      }
    } else {
      // Si l'utilisateur annule, mettez une valeur par défaut ou vide
      if (isOpening) {
        await _updateBusinessHours('', closing_hour);
      } else {
        await _updateBusinessHours(opening_hour, '');
      }
    }
  }
  ////like et comment //////////////////////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getReviewComments(int reviewId) async {
    final response = await supabase
        .from('review_comments')
        .select('id, comment, created_at, user_id')
        .eq('review_id', reviewId)
        .order('created_at', ascending: true);

    return response;
  }

  //// Publier des photos ou vidéos ////////////////////////////////////////////////////////////////////////////
  ///
  ///
  Future<String> uploadMedia(String businessId, XFile xfile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("Non connecté");

    const bucketName = 'business_media'; // Assurez-vous que ce bucket existe

    try {
      // Convertir XFile en File
      final file = File(xfile.path);

      // Vérifier que le fichier existe
      if (!await file.exists()) {
        throw Exception("Le fichier n'existe pas");
      }

      final ext = xfile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath =
          '${businessId}_$fileName'; // Ajouter l'ID business pour l'organisation

      // Upload vers Storage
      final uploadResponse = await Supabase.instance.client.storage
          .from(bucketName)
          .upload(filePath, file);

      if (uploadResponse == null || uploadResponse.isEmpty) {
        throw Exception(
          "Erreur upload: l'upload a échoué ou le chemin est vide.",
        );
      }

      // Récupérer l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      print('Fichier uploadé avec succès: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Erreur uploadMedia: $e');
      rethrow;
    }
  }

  Future<void> addBusinessPost(
    String businessId,
    String mediaUrl,
    String mediaType,
  ) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non authentifié");
      }

      // Vérifier que les champs obligatoires sont présents
      if (businessId.isEmpty) {
        throw Exception("ID business manquant");
      }
      if (mediaUrl.isEmpty) {
        throw Exception("URL média manquant");
      }

      final response = await Supabase.instance.client
          .from('business_posts')
          .insert({
            'business_id': businessId,
            'media_url': mediaUrl,
            'media_type': mediaType,
            'owner_id': user.id,
            'created_at': DateTime.now().toIso8601String(),
          });

      if (response.error != null) {
        throw Exception("Erreur Supabase: ${response.error!.message}");
      }

      if (response.data == null) {
        throw Exception("Aucune donnée retournée");
      }

      print('Post business ajouté avec succès: ${response.data}');
    } on SocketException {
      throw Exception("Problème de connexion internet");
    } on FormatException {
      throw Exception("Format de données invalide");
    } catch (e) {
      print('Erreur détaillée addBusinessPost: $e');
      throw Exception("Erreur lors de l'ajout du post: ${e.toString()}");
    }
  }
  //problem de apload photo pour resoudre ////////

  Future<bool> _checkBucketExists(String bucketName) async {
    try {
      final buckets = await Supabase.instance.client.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);

      if (!bucketExists) {
        // Créer le bucket s'il n'existe pas
        await Supabase.instance.client.storage.createBucket(
          bucketName,
          // ou false selon vos besoins
        );
        print('Bucket $bucketName créé avec succès');
      }

      return true;
    } catch (e) {
      print('Erreur création bucket: $e');
      return false;
    }
  }

  Future<String> uploadBusinessMedia(String businessId, XFile xfile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("Non connecté");

    const bucketName = 'business_media';

    try {
      // Vérifier et créer le bucket si nécessaire
      final bucketReady = await _checkBucketExists(bucketName);
      if (!bucketReady) {
        throw Exception("Impossible de préparer le stockage");
      }

      // Convertir XFile en File
      final file = File(xfile.path);

      // Vérifier la taille du fichier (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception("Le fichier est trop volumineux (max 10MB)");
      }

      final ext = xfile.path.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov'];

      if (!allowedExtensions.contains(ext)) {
        throw Exception("Format de fichier non supporté");
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = '${businessId}_$fileName';

      // Upload vers Storage avec gestion de progression
      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(filePath, file);

      // Récupérer l'URL publique
      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      print('Fichier uploadé avec succès: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Erreur uploadBusinessMedia: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBusinessPosts(String businessId) async {
    final response = await Supabase.instance.client
        .from('business_posts')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _isBusinessOpen();
    if (isLoading)
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    FutureBuilder<List<Map<String, dynamic>>>(
      future: getBusinessPosts(widget.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snapshot.data!;

        return Column(
          children: posts.map((post) {
            final isOwner =
                post['owner_id'] ==
                Supabase.instance.client.auth.currentUser?.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  if (post['media_type'] == 'image')
                    Image.network(post['media_url'])
                  else
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      //  child: VideoPlayerWidget(url: post['media_url']), // ⚡ widget perso à faire
                    ),

                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await Supabase.instance.client
                            .from('business_posts')
                            .delete()
                            .eq('id', post['id']);
                        setState(() {});
                      },
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () async {
                final scaffoldContext = context;

                // Afficher un menu pour choisir entre photo et vidéo
                final source = await showModalBottomSheet<ImageSource>(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Galerie photos'),
                        onTap: () =>
                            Navigator.pop(context, ImageSource.gallery),
                      ),
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Appareil photo'),
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                      ListTile(
                        leading: Icon(Icons.video_library),
                        title: Text('Galerie vidéos'),
                        onTap: () =>
                            Navigator.pop(context, ImageSource.gallery),
                      ),
                    ],
                  ),
                );

                if (source == null) return;

                final picker = ImagePicker();
                final XFile? file;

                if (source == ImageSource.gallery) {
                  // Demander à l'utilisateur ce qu'il veut choisir
                  final mediaType = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Choisir le type de média'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('Photo'),
                            onTap: () => Navigator.pop(context, 'image'),
                          ),
                          ListTile(
                            title: Text('Vidéo'),
                            onTap: () => Navigator.pop(context, 'video'),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (mediaType == null) return;

                  file = mediaType == 'image'
                      ? await picker.pickImage(source: ImageSource.gallery)
                      : await picker.pickVideo(source: ImageSource.gallery);
                } else {
                  file = await picker.pickImage(source: ImageSource.camera);
                }

                if (file != null) {
                  final loadingDialog = showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Téléchargement en cours...'),
                        ],
                      ),
                    ),
                  );

                  try {
                    final mediaUrl = await uploadMedia(widget.id, file);
                    final mediaType =
                        file.path.toLowerCase().contains('.mp4') ||
                            file.path.toLowerCase().contains('.mov')
                        ? 'video'
                        : 'image';

                    await addBusinessPost(widget.id, mediaUrl, mediaType);

                    Navigator.pop(context); // Fermer le loading
                    setState(() {});

                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(content: Text('Média ajouté avec succès!')),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Fermer le loading
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erreur lors de l\'ajout: ${e.toString()}',
                        ),
                      ),
                    );
                  } finally {
                    // S'assurer que le dialog est fermé
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }
                }
              },
              child: const Icon(Icons.add_a_photo),
              backgroundColor: AppColors.primaryBlue,
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 230,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: _image.isNotEmpty && _image.startsWith('http')
                        ? Image.network(_image, fit: BoxFit.cover)
                        : Image.asset(
                            'assets/images/hotel.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (isOwner) // ✅ bouton image profile que si propriétaire
                    Positioned(
                      bottom: 10,
                      left: 120,
                      child: ElevatedButton(
                        onPressed: _pickAndUploadImage,
                        child: const Text("Image Profile"),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' ${nameController.text}',
                        style: AppTextStyles.title,
                      ),

                      Row(
                        children: [
                          Material(
                            borderRadius: BorderRadius.circular(20),
                            elevation: 3,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(Icons.favorite_border),
                                onPressed: _addToFavorites,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Material(
                            borderRadius: BorderRadius.circular(30),
                            elevation: 2,
                            child: IconButton(
                              onPressed: () {
                                final businessId = widget.id;
                                final businessUrl =
                                    'https://sevislakay.com/business/$businessId';

                                Share.share(
                                  'Découvrez ce business sur Sevis Lakay 👇\n$businessUrl',
                                  subject: 'Profil Business Sevis Lakay',
                                );
                              },
                              icon: const Icon(Icons.share),
                              color: Colors.white,
                              iconSize: 20,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  AppColors.primaryBlue,
                                ),
                                shape: MaterialStateProperty.all(
                                  const CircleBorder(),
                                ),
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(11),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  SizedBox(height: 10),
                  Column(
                    children: [
                      // Nouvelle section des horaires
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOpen ? Icons.check_circle : Icons.cancel,
                                  color: isOpen ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  isOpen ? 'OUVERT' : 'FERMÉ',
                                  style: TextStyle(
                                    color: isOpen ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (opening_hour.isNotEmpty &&
                              closing_hour.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '$opening_hour - $closing_hour',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                        ],
                      ),
                      if (isOwner)
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _selectTime(context, true),
                              child: Text(" heure d'ouverture"),
                            ),
                            TextButton(
                              onPressed: () => _selectTime(context, false),
                              child: Text('heure de fermeture'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 10),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text(address),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text(phone),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.wifi_protected_setup,
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(width: 10),
                      Text(email),
                    ],
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: _openMap,
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primaryBlue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'View on Map',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (isOwner) // ✅ bouton modifier que si propriétaire
                    ElevatedButton(
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 16,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nom',
                                    ),
                                  ),
                                  TextField(
                                    controller: hourController,
                                    decoration: InputDecoration(
                                      labelText: 'Heure',
                                    ),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Adresse',
                                    ),
                                    controller: TextEditingController(
                                      text: address,
                                    ),
                                    onChanged: (v) => address = v,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Téléphone',
                                    ),
                                    controller: TextEditingController(
                                      text: phone,
                                    ),
                                    onChanged: (v) => phone = v,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                    ),
                                    controller: TextEditingController(
                                      text: email,
                                    ),
                                    onChanged: (v) => email = v,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'À propos',
                                    ),
                                    controller: TextEditingController(
                                      text: description,
                                    ),
                                    onChanged: (v) => description = v,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await Supabase.instance.client
                                          .from('business_accounts')
                                          .update({
                                            'name': nameController.text,
                                            'openingHour': hourController.text,
                                            'address': address,
                                            'phone': phone,
                                            'email': email,
                                            'description': description,
                                          })
                                          .eq('id', widget.id);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      await _loadData();
                                    },
                                    child: Text('Enregistrer'),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOpen ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        await _loadData();
                      },
                      child: Text('Modifier'),
                    ),
                  Divider(height: 10),
                  SizedBox(height: 20),

                  SizedBox(height: 20),
                  CustomDropdown(),

                  Divider(height: 10),
                  SizedBox(height: 20),
                  Text('About', style: AppTextStyles.titleItem),
                  Text(description),
                  SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getBusinessPosts(widget.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!;
                      if (posts.isEmpty) {
                        return const Center(
                          child: Text("Aucun média publié pour l’instant"),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap:
                            true, // pour l’utiliser dans un SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 colonnes comme Instagram
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isOwner =
                              post['owner_id'] ==
                              Supabase.instance.client.auth.currentUser?.id;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    backgroundColor: Colors.black,
                                    appBar: AppBar(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      actions: isOwner
                                          ? [
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () async {},
                                              ),
                                            ]
                                          : null,
                                    ),
                                    body: Center(
                                      child: post['media_type'] == 'image'
                                          ? InteractiveViewer(
                                              minScale: 0.5,
                                              maxScale: 4.0,
                                              child: Image.network(
                                                post['media_url'],
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                          : AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: VideoPlayerWidget(
                                                url: post['media_url'],
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                // Conteneur principal pour le média
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey[200], // Couleur de fond
                                    child: post['media_type'] == 'image'
                                        ? Image.network(
                                            post['media_url'],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value:
                                                      loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.red,
                                                    size: 40,
                                                  );
                                                },
                                          )
                                        : Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Vous pourriez ajouter une miniature vidéo ici si disponible
                                              Container(
                                                color: Colors.black,
                                                child: const Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                              // Indicateur que c'est une vidéo
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.videocam,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                // Bouton de suppression (seulement pour le propriétaire)
                                if (isOwner)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Ajouter une confirmation avant suppression
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Confirmer la suppression',
                                            ),
                                            content: const Text(
                                              'Êtes-vous sûr de vouloir supprimer ce média ?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text(
                                                  'Supprimer',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          try {
                                            await Supabase.instance.client
                                                .from('business_posts')
                                                .delete()
                                                .eq('id', post['id']);

                                            // Rafraîchir l'interface
                                            if (mounted) {
                                              setState(() {});
                                            }

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Média supprimé avec succès',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erreur lors de la suppression: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  Divider(height: 10),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButtonIcons(
                        borderColor: AppColors.primaryBlue,
                        backgroundColor: AppColors.primaryBlue,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        icons: Icons.location_pin,
                        title: 'Get Directions',
                      ),
                    ],
                  ),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: getReviews(),
                    builder: (context, snapshot) {
                      // Gestion de l'état de chargement
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Gestion des erreurs
                      if (snapshot.hasError) {
                        return const Text('Erreur de chargement des avis');
                      }

                      // Maintenant nous sommes sûrs d'avoir des données
                      final reviews = snapshot.data ?? [];

                      // Cas où il n'y a aucun avis
                      if (reviews.isEmpty) {
                        return Column(
                          children: [
                            if (!hasUserReviewed)
                              Padding(
                                padding: const EdgeInsets.only(left: 60),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_border,
                                      color: AppColors.primaryBlue,
                                      size: 100,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Be the first to review this business',
                                    ),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => WriteReviewScreen(
                                              businessId: widget.id,
                                            ),
                                          ),
                                        ).then(
                                          (_) => _checkIfUserHasReviewed(),
                                        );
                                      },
                                      child: MyButtonIcons(
                                        borderColor: AppColors.primaryBlue,
                                        backgroundColor: Colors.white,
                                        iconColor: AppColors.primaryBlue,
                                        textColor: AppColors.primaryBlue,
                                        icons: Icons.star,
                                        title: 'Write a Review',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }

                      // Cas où il y a des avis
                      return Column(
                        children: [
                          if (!hasUserReviewed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WriteReviewScreen(
                                        businessId: widget.id,
                                      ),
                                    ),
                                  ).then((_) => _checkIfUserHasReviewed());
                                },
                                child: MyButtonIcons(
                                  borderColor: AppColors.primaryBlue,
                                  backgroundColor: Colors.white,
                                  iconColor: AppColors.primaryBlue,
                                  textColor: AppColors.primaryBlue,
                                  icons: Icons.star,
                                  title: 'Write a Review',
                                ),
                              ),
                            ),
                          ...reviews.map((review) {
                            final reviewId =
                                review['id']; // Assure-toi que la colonne id est sélectionnée dans getReviews()
                            final user =
                                Supabase.instance.client.auth.currentUser;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    title: Text(
                                      '${review['rating']?.toString() ?? '0'} / 5',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      review['comment']?.toString() ?? '',
                                    ),
                                    trailing: Text(
                                      review['created_at'] != null
                                          ? DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(
                                                review['created_at'],
                                              ).toLocal(),
                                            )
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  // === Bouton Like ===
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: Supabase.instance.client
                                        .from('review_likes')
                                        .select()
                                        .eq('review_id', reviewId),
                                    builder: (context, likeSnapshot) {
                                      if (!likeSnapshot.hasData) {
                                        return const SizedBox.shrink();
                                      }
                                      final likes = likeSnapshot.data!;
                                      final likeCount = likes.length;
                                      final hasLiked = likes.any(
                                        (l) => l['user_id'] == user?.id,
                                      );

                                      return Row(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              if (user == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Connectez-vous pour liker',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              if (hasLiked) {
                                                // retirer like
                                                await Supabase.instance.client
                                                    .from('review_likes')
                                                    .delete()
                                                    .eq('review_id', reviewId)
                                                    .eq('user_id', user!.id);
                                              } else {
                                                // ajouter like
                                                await Supabase.instance.client
                                                    .from('review_likes')
                                                    .insert({
                                                      'review_id': reviewId,
                                                      'user_id': user!.id,
                                                    });
                                              }
                                              setState(
                                                () {},
                                              ); // 🔄 recharge l'UI
                                            },
                                            icon: Icon(
                                              hasLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: hasLiked
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                          Text('$likeCount likes'),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
