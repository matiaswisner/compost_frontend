import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'create_post_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final ApiService apiService = ApiService();
final LocationService locationService = LocationService();

Future<List<Post>>? postsFuture;

Position? currentPosition;

@override
void initState() {
super.initState();
initialize();
}

Future<void> initialize() async {
try {
currentPosition =
await locationService.getCurrentLocation();
} catch (_) {}

setState(() {
loadPosts();
});
}

void loadPosts() {
postsFuture = loadAndProcessPosts();
}

Future<List<Post>> loadAndProcessPosts() async {
final posts = await apiService.getPosts();

if (currentPosition != null) {
for (var post in posts) {
final meters = Geolocator.distanceBetween(
currentPosition!.latitude,
currentPosition!.longitude,
post.lat,
post.lng,
);

post.distanceKm = meters / 1000;
}

posts.sort((a, b) {
final da = a.distanceKm ?? 999999;
final db = b.distanceKm ?? 999999;

return da.compareTo(db);
});
}

return posts;
}

void refreshPosts() {
setState(() {
loadPosts();
});
}

Future<void> openCreatePost() async {
final result = await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const CreatePostScreen(),
),
);

if (result == true) {
refreshPosts();
}
}

void openProfile() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const ProfileScreen(),
),
);
}

void openMap() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const MapScreen(),
),
);
}

Color getTypeColor(String type) {
if (type == 'OFFER') {
return const Color(0xFF2E7D32);
}

if (type == 'NEED') {
return const Color(0xFFC62828);
}

return Colors.grey;
}

String getTypeText(String type) {
if (type == 'OFFER') {
return 'OFREZCO';
}

if (type == 'NEED') {
return 'NECESITO';
}

return type;
}

String formatUnit(String unit) {
switch (unit) {
case 'KG':
return 'kg';

case 'TON':
return 'ton';

case 'M3':
return 'm³';

case 'BAG':
return 'bolsas';

default:
return unit;
}
}

String formatDistance(double? km) {
if (km == null) {
return 'Ubicación no disponible';
}

if (km < 1) {
return '${(km * 1000).toStringAsFixed(0)} m';
}

return '${km.toStringAsFixed(1)} km';
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF5FAFC),

appBar: AppBar(
elevation: 0,
title: const Text(
'CompostApp',
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 28,
),
),
backgroundColor: const Color(0xFF6EC1E4),
foregroundColor: Colors.white,
actions: [
IconButton(
onPressed: refreshPosts,
icon: const Icon(Icons.refresh),
),
IconButton(
onPressed: openMap,
icon: const Icon(Icons.map),
),
IconButton(
onPressed: openProfile,
icon: const Icon(Icons.person),
),
],
),

floatingActionButton: FloatingActionButton(
onPressed: openCreatePost,
backgroundColor: const Color(0xFF2E7D32),
child: const Icon(Icons.add),
),

body: FutureBuilder<List<Post>>(
future: postsFuture ?? apiService.getPosts(),
builder: (context, snapshot) {
if (postsFuture == null ||
snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Text(
'No se pudieron cargar las publicaciones.\n\n${snapshot.error}',
textAlign: TextAlign.center,
),
),
);
}

final posts = snapshot.data ?? [];

if (posts.isEmpty) {
return const Center(
child: Text(
'Todavía no hay publicaciones.',
style: TextStyle(fontSize: 16),
),
);
}

return RefreshIndicator(
onRefresh: () async {
refreshPosts();
},
child: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: posts.length,
itemBuilder: (context, index) {
final post = posts[index];

return AnimatedContainer(
duration:
const Duration(milliseconds: 300),
curve: Curves.easeInOut,
child: Card(
elevation: 4,
margin:
const EdgeInsets.only(bottom: 16),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(22),
),
child: Padding(
padding: const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,
children: [
Container(
padding:
const EdgeInsets
    .symmetric(
horizontal: 12,
vertical: 7,
),
decoration: BoxDecoration(
color: getTypeColor(
post.type,
),
borderRadius:
BorderRadius
    .circular(
30,
),
),
child: Text(
getTypeText(post.type),
style:
const TextStyle(
color: Colors.white,
fontSize: 12,
fontWeight:
FontWeight
    .bold,
),
),
),

const Icon(
Icons.eco,
color:
Color(0xFF2E7D32),
),
],
),

const SizedBox(height: 16),

Text(
post.title,
style: const TextStyle(
fontSize: 24,
fontWeight:
FontWeight.bold,
color:
Color(0xFF1F1F1F),
),
),

const SizedBox(height: 8),

Text(
post.description,
style: const TextStyle(
fontSize: 16,
height: 1.4,
color: Colors.black87,
),
),

const SizedBox(height: 18),

Row(
children: [
const Icon(
Icons.recycling,
size: 18,
),

const SizedBox(width: 8),

Text(
post.materialName,
style:
const TextStyle(
fontSize: 16,
),
),
],
),

const SizedBox(height: 10),

Row(
children: [
const Icon(
Icons.scale,
size: 18,
),

const SizedBox(width: 8),

Text(
'${post.quantity.toStringAsFixed(0)} ${formatUnit(post.unit)}',
style:
const TextStyle(
fontSize: 16,
),
),
],
),

const SizedBox(height: 10),

Row(
children: [
const Icon(
Icons.location_on,
size: 18,
color: Colors.red,
),

const SizedBox(width: 8),

Text(
formatDistance(
post.distanceKm,
),
style:
const TextStyle(
fontSize: 15,
fontWeight:
FontWeight.w600,
),
),
],
),

const SizedBox(height: 10),

Row(
children: [
const Icon(
Icons.person,
size: 18,
color: Colors.blue,
),

const SizedBox(width: 8),

Text(
post.userName,
style:
const TextStyle(
fontSize: 16,
),
),
],
),
],
),
),
),
);
},
),
);
},
),
);
}
}
