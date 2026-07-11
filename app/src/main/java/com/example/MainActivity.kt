package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.*

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    setContent {
      MyApplicationTheme {
        Scaffold(
          modifier = Modifier.fillMaxSize()
        ) { innerPadding ->
          NexoraDashboard(modifier = Modifier.padding(innerPadding))
        }
      }
    }
  }
}

// Data models for the architecture explorer
data class FileNode(
  val name: String,
  val isDirectory: Boolean,
  val path: String,
  val description: String,
  val beginnerTip: String,
  val codeSample: String,
  val icon: ImageVector,
  val children: List<FileNode> = emptyList()
)

data class TechMapItem(
  val feature: String,
  val flutterTech: String,
  val flutterDesc: String,
  val nativeTech: String,
  val nativeDesc: String,
  val icon: ImageVector
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NexoraDashboard(modifier: Modifier = Modifier) {
  var selectedTab by remember { mutableIntStateOf(0) }

  Column(
    modifier = modifier
      .fillMaxSize()
      .background(MaterialTheme.colorScheme.background)
  ) {
    // Header Banner
    Box(
      modifier = Modifier
        .fillMaxWidth()
        .background(
          Brush.verticalGradient(
            colors = listOf(
              MaterialTheme.colorScheme.primary.copy(alpha = 0.15f),
              Color.Transparent
            )
          )
        )
        .padding(horizontal = 24.dp, vertical = 20.dp)
    ) {
      Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = Modifier.fillMaxWidth()
      ) {
        Column {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
              imageVector = Icons.Filled.PlayCircle,
              contentDescription = "Nexora Logo",
              tint = MaterialTheme.colorScheme.primary,
              modifier = Modifier.size(28.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
              text = "NEXORA",
              fontSize = 24.sp,
              fontWeight = FontWeight.Bold,
              letterSpacing = 2.sp,
              color = Color.White
            )
          }
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "Modern IPTV Player Architecture Shell",
            fontSize = 12.sp,
            color = NexoraMutedText
          )
        }
        
        Surface(
          color = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
          border = ButtonDefaults.outlinedButtonBorder,
          shape = RoundedCornerShape(100.dp)
        ) {
          Text(
            text = "COMPILE READY",
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
          )
        }
      }
    }

    // Material 3 Tabs
    TabRow(
      selectedTabIndex = selectedTab,
      containerColor = Color.Transparent,
      contentColor = MaterialTheme.colorScheme.primary
    ) {
      Tab(
        selected = selectedTab == 0,
        onClick = { selectedTab = 0 },
        text = { Text("Structure Explorer", fontSize = 13.sp, fontWeight = FontWeight.Bold) },
        icon = { Icon(Icons.Outlined.Folder, contentDescription = null, modifier = Modifier.size(20.dp)) }
      )
      Tab(
        selected = selectedTab == 1,
        onClick = { selectedTab = 1 },
        text = { Text("Technology Mapping", fontSize = 13.sp, fontWeight = FontWeight.Bold) },
        icon = { Icon(Icons.Outlined.SwapHoriz, contentDescription = null, modifier = Modifier.size(20.dp)) }
      )
      Tab(
        selected = selectedTab == 2,
        onClick = { selectedTab = 2 },
        text = { Text("Architecture Rules", fontSize = 13.sp, fontWeight = FontWeight.Bold) },
        icon = { Icon(Icons.Outlined.Assignment, contentDescription = null, modifier = Modifier.size(20.dp)) }
      )
    }

    // Tab Contents
    Box(
      modifier = Modifier
        .fillMaxWidth()
        .weight(1f)
        .padding(16.dp)
    ) {
      when (selectedTab) {
        0 -> StructureExplorerScreen()
        1 -> TechnologyMappingScreen()
        2 -> ArchitectureRulesScreen()
      }
    }
  }
}

@Composable
fun StructureExplorerScreen() {
  val files = remember { getMockStructure() }
  var selectedNode by remember { mutableStateOf<FileNode?>(files[0]) }

  Row(modifier = Modifier.fillMaxSize(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
    // Left Pane: File Tree
    Card(
      modifier = Modifier
        .weight(1.1f)
        .fillMaxHeight(),
      colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
      Column(modifier = Modifier.padding(12.dp)) {
        Text(
          text = "PROJECT DIRECTORIES",
          fontSize = 11.sp,
          fontWeight = FontWeight.Bold,
          color = NexoraMutedText,
          modifier = Modifier.padding(start = 8.dp, bottom = 8.dp)
        )
        
        LazyColumn(
          verticalArrangement = Arrangement.spacedBy(4.dp),
          modifier = Modifier.fillMaxSize()
        ) {
          items(files) { node ->
            FileNodeItem(
              node = node,
              depth = 0,
              selectedNode = selectedNode,
              onNodeClick = { selectedNode = it }
            )
          }
        }
      }
    }

    // Right Pane: Description & Teacher Notes
    Card(
      modifier = Modifier
        .weight(1.3f)
        .fillMaxHeight(),
      colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
    ) {
      Box(modifier = Modifier.fillMaxSize()) {
        if (selectedNode != null) {
          val node = selectedNode!!
          LazyColumn(
            modifier = Modifier
              .fillMaxSize()
              .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
          ) {
            item {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                  imageVector = node.icon,
                  contentDescription = null,
                  tint = if (node.isDirectory) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.primary,
                  modifier = Modifier.size(32.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                  Text(
                    text = node.name,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                  )
                  Text(
                    text = node.path,
                    fontSize = 11.sp,
                    fontFamily = FontFamily.Monospace,
                    color = NexoraMutedText
                  )
                }
              }
            }

            item {
              Divider(color = Color.White.copy(alpha = 0.1f))
            }

            item {
              Column {
                Text(
                  text = "RESPONSIBILITY",
                  fontSize = 11.sp,
                  fontWeight = FontWeight.Bold,
                  color = MaterialTheme.colorScheme.primary,
                  letterSpacing = 1.sp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                  text = node.description,
                  fontSize = 14.sp,
                  color = Color.White.copy(alpha = 0.9f),
                  lineHeight = 20.sp
                )
              }
            }

            item {
              Column(
                modifier = Modifier
                  .fillMaxWidth()
                  .clip(RoundedCornerShape(12.dp))
                  .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.05f))
                  .padding(12.dp)
              ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Icon(
                    imageVector = Icons.Outlined.School,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(18.dp)
                  )
                  Spacer(modifier = Modifier.width(8.dp))
                  Text(
                    text = "TEACHER'S NOTE FOR BEGINNERS",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                  )
                }
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                  text = node.beginnerTip,
                  fontSize = 13.sp,
                  color = Color.White.copy(alpha = 0.8f),
                  lineHeight = 18.sp
                )
              }
            }

            if (node.codeSample.isNotEmpty()) {
              item {
                Column {
                  Text(
                    text = "STRUCTURE PREVIEW",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.secondary,
                    letterSpacing = 1.sp
                  )
                  Spacer(modifier = Modifier.height(6.dp))
                  Box(
                    modifier = Modifier
                      .fillMaxWidth()
                      .clip(RoundedCornerShape(8.dp))
                      .background(Color.Black.copy(alpha = 0.4f))
                      .padding(12.dp)
                  ) {
                    Text(
                      text = node.codeSample,
                      fontSize = 11.sp,
                      fontFamily = FontFamily.Monospace,
                      color = Color(0xFFA5D6A7),
                      lineHeight = 16.sp
                    )
                  }
                }
              }
            }
          }
        } else {
          Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
          ) {
            Text(
              text = "Select a file or folder from the tree to explore.",
              color = NexoraMutedText,
              fontSize = 14.sp,
              textAlign = TextAlign.Center,
              modifier = Modifier.padding(24.dp)
            )
          }
        }
      }
    }
  }
}

@Composable
fun FileNodeItem(
  node: FileNode,
  depth: Int,
  selectedNode: FileNode?,
  onNodeClick: (FileNode) -> Unit
) {
  var isExpanded by remember { mutableStateOf(depth < 1) } // Expand top levels automatically
  val isSelected = selectedNode == node

  Column {
    Row(
      verticalAlignment = Alignment.CenterVertically,
      modifier = Modifier
        .fillMaxWidth()
        .clip(RoundedCornerShape(8.dp))
        .background(
          if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)
          else Color.Transparent
        )
        .clickable {
          onNodeClick(node)
          if (node.isDirectory) {
            isExpanded = !isExpanded
          }
        }
        .padding(horizontal = 8.dp, vertical = 6.dp)
        .padding(start = (depth * 12).dp)
    ) {
      if (node.isDirectory) {
        Icon(
          imageVector = if (isExpanded) Icons.Filled.ArrowDropDown else Icons.Filled.ArrowRight,
          contentDescription = null,
          tint = NexoraMutedText,
          modifier = Modifier.size(18.dp)
        )
      } else {
        Spacer(modifier = Modifier.width(18.dp))
      }

      Icon(
        imageVector = node.icon,
        contentDescription = null,
        tint = if (node.isDirectory) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.primary,
        modifier = Modifier.size(16.dp)
      )
      Spacer(modifier = Modifier.width(6.dp))
      Text(
        text = node.name,
        fontSize = 13.sp,
        fontWeight = if (node.isDirectory) FontWeight.SemiBold else FontWeight.Normal,
        color = if (isSelected) MaterialTheme.colorScheme.primary else Color.White
      )
    }

    if (node.isDirectory && isExpanded) {
      node.children.forEach { child ->
        FileNodeItem(
          node = child,
          depth = depth + 1,
          selectedNode = selectedNode,
          onNodeClick = onNodeClick
        )
      }
    }
  }
}

@Composable
fun TechnologyMappingScreen() {
  val mappings = remember { getTechMappings() }

  Column(modifier = Modifier.fillMaxSize()) {
    Text(
      text = "TECHNOLOGY EQUIVALENT MAP",
      fontSize = 11.sp,
      fontWeight = FontWeight.Bold,
      color = NexoraMutedText,
      letterSpacing = 1.sp,
      modifier = Modifier.padding(bottom = 12.dp)
    )
    
    LazyColumn(
      verticalArrangement = Arrangement.spacedBy(12.dp),
      modifier = Modifier.fillMaxSize()
    ) {
      items(mappings) { item ->
        Card(
          colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
        ) {
          Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Icon(
                imageVector = item.icon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(20.dp)
              )
              Spacer(modifier = Modifier.width(8.dp))
              Text(
                text = item.feature,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
              )
            }
            Spacer(modifier = Modifier.height(12.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
              // Flutter Side
              Box(
                modifier = Modifier
                  .weight(1f)
                  .clip(RoundedCornerShape(8.dp))
                  .background(Color.White.copy(alpha = 0.03f))
                  .padding(10.dp)
              ) {
                Column {
                  Text(text = "FLUTTER", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.secondary)
                  Spacer(modifier = Modifier.height(4.dp))
                  Text(text = item.flutterTech, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color.White)
                  Spacer(modifier = Modifier.height(2.dp))
                  Text(text = item.flutterDesc, fontSize = 11.sp, color = NexoraMutedText, lineHeight = 15.sp)
                }
              }
              
              // Native Android Side
              Box(
                modifier = Modifier
                  .weight(1f)
                  .clip(RoundedCornerShape(8.dp))
                  .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.05f))
                  .padding(10.dp)
              ) {
                Column {
                  Text(text = "NATIVE ANDROID", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                  Spacer(modifier = Modifier.height(4.dp))
                  Text(text = item.nativeTech, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color.White)
                  Spacer(modifier = Modifier.height(2.dp))
                  Text(text = item.nativeDesc, fontSize = 11.sp, color = NexoraMutedText, lineHeight = 15.sp)
                }
              }
            }
          }
        }
      }
    }
  }
}

@Composable
fun ArchitectureRulesScreen() {
  LazyColumn(
    modifier = Modifier.fillMaxSize(),
    verticalArrangement = Arrangement.spacedBy(16.dp)
  ) {
    item {
      Text(
        text = "CLEAN ARCHITECTURE CORE PRINCIPLES",
        fontSize = 11.sp,
        fontWeight = FontWeight.Bold,
        color = NexoraMutedText,
        letterSpacing = 1.sp
      )
    }

    item {
      RuleCard(
        title = "1. Separation of Concerns",
        description = "In Nexora, UI (screens & widgets) must NEVER talk directly to network endpoints or database files. The UI only monitors States (from Providers/ViewModels) and triggers events. Services handle parsing and fetching in isolated layers.",
        icon = Icons.Outlined.Layers
      )
    }

    item {
      RuleCard(
        title = "2. Immutable Data Models",
        description = "Our model files (Channel, Category, Playlist) are completely immutable (using final properties). To change state, we utilize the copyWith() method to emit a brand new instance. This prevents data leakage and side-effects.",
        icon = Icons.Outlined.GridOn
      )
    }

    item {
      RuleCard(
        title = "3. Clean Dependency Direction",
        description = "The inner core layers (Entities/Models) do not know about the outer layers (API, Storage, UI). This makes our code completely testable and swappable. We can replace Shared Preferences with SQLite/Room tomorrow without touching a single screen file!",
        icon = Icons.Outlined.Share
      )
    }

    item {
      RuleCard(
        title = "4. Single Source of Truth",
        description = "State is stored in centralized memory providers. Every component (like active mini-players, list grids) listens to the same Riverpod / StateFlow provider. This guarantees consistent synchronization in layout components.",
        icon = Icons.Outlined.CheckCircle
      )
    }
  }
}

@Composable
fun RuleCard(title: String, description: String, icon: ImageVector) {
  Card(
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
  ) {
    Row(
      modifier = Modifier
        .fillMaxWidth()
        .padding(16.dp),
      verticalAlignment = Alignment.Top
    ) {
      Icon(
        imageVector = icon,
        contentDescription = null,
        tint = MaterialTheme.colorScheme.primary,
        modifier = Modifier
          .size(24.dp)
          .padding(top = 2.dp)
      )
      Spacer(modifier = Modifier.width(16.dp))
      Column {
        Text(
          text = title,
          fontSize = 15.sp,
          fontWeight = FontWeight.Bold,
          color = Color.White
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
          text = description,
          fontSize = 13.sp,
          color = NexoraMutedText,
          lineHeight = 18.sp
        )
      }
    }
  }
}

fun getMockStructure(): List<FileNode> {
  return listOf(
    FileNode(
      name = "nexora",
      isDirectory = true,
      path = "/",
      description = "The root of your Flutter workspace containing metadata, dependencies, static configuration files, and core source folders.",
      beginnerTip = "Always look at pubspec.yaml first when exploring any Flutter project, as it tells you the third-party engines and libraries supporting the application.",
      codeSample = "",
      icon = Icons.Outlined.FolderOpen,
      children = listOf(
        FileNode(
          name = "pubspec.yaml",
          isDirectory = false,
          path = "/pubspec.yaml",
          description = "The metadata registry for Flutter. Declares the app version, project dependencies, development packages, assets (images, animations, fonts), and design constraints.",
          beginnerTip = "When you add an asset in the folders (like assets/logos), you must register it here under the 'flutter:' section so that Dart can find it at runtime.",
          codeSample = "dependencies:\n  flutter_riverpod: ^2.5.1\n  go_router: ^14.0.1\n  shared_preferences: ^2.2.3\n  http: ^1.2.1",
          icon = Icons.Outlined.Description
        ),
        FileNode(
          name = "analysis_options.yaml",
          isDirectory = false,
          path = "/analysis_options.yaml",
          description = "Configures compiler rules, warning thresholds, and stylistic guidelines for code linting.",
          beginnerTip = "Lints act like a coding assistant that alerts you to bad syntax patterns before compiling. Keeping strict rules makes the codebase robust.",
          codeSample = "analyzer:\n  language:\n    strict-casts: true\n    strict-inference: true\nlinter:\n  rules:\n    - prefer_const_constructors\n    - always_declare_return_types",
          icon = Icons.Outlined.SettingsSuggest
        ),
        FileNode(
          name = "README.md",
          isDirectory = false,
          path = "/README.md",
          description = "The documentation portal describing the IPTV Player project setup, architecture layout, and deployment instructions.",
          beginnerTip = "Always keep this file up-to-date with custom deployment guidelines for new developers joining the team.",
          codeSample = "# Nexora IPTV Player\n\n- Built using GoRouter, Riverpod, and Clean Architecture.\n- Run: flutter run --release",
          icon = Icons.Outlined.Info
        ),
        FileNode(
          name = "assets",
          isDirectory = true,
          path = "/assets",
          description = "Houses raw resources, graphical animations, branding assets, custom fonts, and static vectors.",
          beginnerTip = "Keep this folder tidy. Subdividing assets into fonts, logos, and animations is an industry best practice.",
          codeSample = "",
          icon = Icons.Outlined.Folder,
          children = listOf(
            FileNode(
              name = "animations",
              isDirectory = false,
              path = "/assets/animations",
              description = "Holds animations like Lottie json files and Rive files for rich state transitions.",
              beginnerTip = "Use subtle transitions (under 300ms) to make the IPTV screen feel lightning fast.",
              codeSample = "",
              icon = Icons.Outlined.Animation
            ),
            FileNode(
              name = "fonts",
              isDirectory = false,
              path = "/assets/fonts",
              description = "Stores clean, highly legible typography formats (.ttf or .otf).",
              beginnerTip = "Ensure we pair display headings with Inter/Roboto body fonts for maximum readability.",
              codeSample = "",
              icon = Icons.Outlined.FontDownload
            ),
            FileNode(
              name = "logos",
              isDirectory = false,
              path = "/assets/logos",
              description = "Holds branding visuals for splash loaders and headers.",
              beginnerTip = "Store transparent PNGs and vector SVGs to keep the logo sharp on high-density screens.",
              codeSample = "",
              icon = Icons.Outlined.FilterFrames
            )
          )
        ),
        FileNode(
          name = "lib",
          isDirectory = true,
          path = "/lib",
          description = "The primary source directory where all Flutter Dart classes reside.",
          beginnerTip = "All of your feature code starts here. Our structure divides this into clean, decoupled layers.",
          codeSample = "",
          icon = Icons.Outlined.FolderSpecial,
          children = listOf(
            FileNode(
              name = "main.dart",
              isDirectory = false,
              path = "/lib/main.dart",
              description = "The absolute main entry point of the Flutter application. Bootstraps the ProviderScope, configures GoRouter routes, and initializes the Material 3 Dark theme.",
              beginnerTip = "This is the very first file executed. Keep it clean and place complex initialization logic into helper services instead of overloading main().",
              codeSample = "void main() {\n  WidgetsFlutterBinding.ensureInitialized();\n  runApp(\n    ProviderScope(child: NexoraApp()),\n  );\n}",
              icon = Icons.Outlined.PlayCircleFilled
            ),
            FileNode(
              name = "core",
              isDirectory = true,
              path = "/lib/core",
              description = "Houses utilities, standard constants, error failures, and client setups that are shared globally across all features.",
              beginnerTip = "Core should never depend on features, but features are allowed to depend on Core.",
              codeSample = "",
              icon = Icons.Outlined.HomeRepairService,
              children = listOf(
                FileNode(
                  name = "constants",
                  isDirectory = false,
                  path = "/lib/core/constants",
                  description = "Holds global parameters like API keys, shared preferences tokens, and asset path strings.",
                  beginnerTip = "Never hardcode database keys inside screens! Register them here as static const variables.",
                  codeSample = "class AppConstants {\n  static const String appName = 'Nexora';\n  static const String prefPlaylistsKey = 'nexora_playlists';\n}",
                  icon = Icons.Outlined.TextSnippet
                ),
                FileNode(
                  name = "errors",
                  isDirectory = false,
                  path = "/lib/core/errors",
                  description = "Standardizes Clean Architecture failure definitions (e.g., ServerFailure, ParseFailure).",
                  beginnerTip = "Wrapping Dart exceptions into visual Failures ensures that the UI can catch errors and show friendly messages.",
                  codeSample = "abstract class Failure {\n  final String message;\n  const Failure(this.message);\n}",
                  icon = Icons.Outlined.ReportProblem
                ),
                FileNode(
                  name = "network",
                  isDirectory = false,
                  path = "/lib/core/network",
                  description = "Manages connection checks and network layer configurations.",
                  beginnerTip = "Use this to verify whether the user has internet before triggering a streaming player load, avoiding annoying infinite spins.",
                  codeSample = "abstract class NetworkInfo {\n  Future<bool> get isConnected;\n}",
                  icon = Icons.Outlined.NetworkCheck
                )
              )
            ),
            FileNode(
              name = "models",
              isDirectory = true,
              path = "/lib/models",
              description = "Data blueprints (entities) representing core domain units (Channels, Playlists, Categories).",
              beginnerTip = "These models are immutable and map network JSON structures safely into compile-safe Dart objects.",
              codeSample = "",
              icon = Icons.Outlined.Storage,
              children = listOf(
                FileNode(
                  name = "channel_model.dart",
                  isDirectory = false,
                  path = "/lib/models/channel_model.dart",
                  description = "Blueprint for an IPTV stream (id, name, streamUrl, logo, categoryId).",
                  beginnerTip = "This model matches standard tvg-tags in M3U file formats.",
                  codeSample = "class ChannelModel {\n  final String id;\n  final String name;\n  final String streamUrl;\n}",
                  icon = Icons.Outlined.Dvr
                ),
                FileNode(
                  name = "playlist_model.dart",
                  isDirectory = false,
                  path = "/lib/models/playlist_model.dart",
                  description = "Blueprints for an imported IPTV source (M3U file or Xtream Codes server credentials).",
                  beginnerTip = "Contains meta info like sync timestamps and channel counts.",
                  codeSample = "class PlaylistModel {\n  final String id;\n  final String name;\n  final PlaylistType type;\n}",
                  icon = Icons.Outlined.PlaylistPlay
                )
              )
            ),
            FileNode(
              name = "services",
              isDirectory = true,
              path = "/lib/services",
              description = "Operational layer carrying out technical work like parsing M3Us, communicating with APIs, or reading local caches.",
              beginnerTip = "Services are purely functional classes designed to run business logic in background thread routines.",
              codeSample = "",
              icon = Icons.Outlined.Memory,
              children = listOf(
                FileNode(
                  name = "api",
                  isDirectory = false,
                  path = "/lib/services/api",
                  description = "Handles HTTP client connections and login calls.",
                  beginnerTip = "Keeps raw networking operations away from the UI code, fully decoupling API logic.",
                  codeSample = "class ApiService {\n  Future<String> fetchM3u(String url) async {}\n}",
                  icon = Icons.Outlined.CloudQueue
                ),
                FileNode(
                  name = "storage",
                  isDirectory = false,
                  path = "/lib/services/storage",
                  description = "Wraps SharedPreferences database calls to load and save playlists on disk.",
                  beginnerTip = "Always encode complex class objects into standard JSON maps before writing them to local storage.",
                  codeSample = "class StorageService {\n  Future<void> savePlaylists(List<PlaylistModel> list) {}\n}",
                  icon = Icons.Outlined.SdCard
                )
              )
            ),
            FileNode(
              name = "providers",
              isDirectory = false,
              path = "/lib/providers",
              description = "Centralized Riverpod state management. Holds active channel info and active filters.",
              beginnerTip = "Provides reactive state fields. When a state modifies (like active channel changes), any listening screens rebuild automatically.",
              codeSample = "final activeChannelProvider = StateProvider<ChannelModel?>((ref) => null);",
              icon = Icons.Outlined.Bolt
            ),
            FileNode(
              name = "screens",
              isDirectory = true,
              path = "/lib/screens",
              description = "The standard high-level visual views representing complete layout states (Splash, Home, Favorites, Live TV, Settings).",
              beginnerTip = "Screens compile multiple widgets together. They should not declare custom small buttons or cards—use components instead.",
              codeSample = "",
              icon = Icons.Outlined.FeaturedPlayList,
              children = listOf(
                FileNode(
                  name = "home",
                  isDirectory = false,
                  path = "/lib/screens/home",
                  description = "Landing screen representing dashboard stats, list of playlists, and import cards.",
                  beginnerTip = "Use clean Empty State views here to guide users on their first launch.",
                  codeSample = "class HomePage extends StatelessWidget {}",
                  icon = Icons.Outlined.Dashboard
                ),
                FileNode(
                  name = "live_tv",
                  isDirectory = false,
                  path = "/lib/screens/live_tv",
                  description = "Standard live player screen where users browse categories and open streams.",
                  beginnerTip = "Keep the categories list at the top as horizontally scrolling pills to maximize screen real estate.",
                  codeSample = "class LiveTvPage extends StatelessWidget {}",
                  icon = Icons.Outlined.LiveTv
                )
              )
            )
          )
        )
      )
    )
  );
}

fun getTechMappings(): List<TechMapItem> {
  return listOf(
    TechMapItem(
      feature = "State Management",
      flutterTech = "Riverpod",
      flutterDesc = "Centralized, compile-safe, and highly optimized reactive state tracking system using Providers and StateNotifier.",
      nativeTech = "ViewModel + StateFlow",
      nativeDesc = "Centralizes system UI data. Mutates via StateFlow/SharedFlow, triggering automatic recompositions in Compose.",
      icon = Icons.Outlined.Hub
    ),
    TechMapItem(
      feature = "Routing & Navigation",
      flutterTech = "GoRouter",
      flutterDesc = "Declarative, URL-driven router package. Supports nested route nodes, parameters, redirects, and clean backstack actions.",
      nativeTech = "Jetpack Navigation",
      nativeDesc = "Type-safe Compose navigation. Maps destinations using serializable routes and triggers smooth cross-screen transitions.",
      icon = Icons.Outlined.Map
    ),
    TechMapItem(
      feature = "API Connections",
      flutterTech = "HTTP Package",
      flutterDesc = "Standard light http library executing REST calls, setting request heads, and retrieving response bodies.",
      nativeTech = "Retrofit + OkHttp",
      nativeDesc = "Compile-safe REST engine wrapping standard APIs into clean interfaces. Leverages robust OkHttp connection pooling.",
      icon = Icons.Outlined.Wifi
    ),
    TechMapItem(
      feature = "Local Storage",
      flutterTech = "Shared Preferences",
      flutterDesc = "Simple key-value dictionary engine persisting string parameters, configurations, and light lists locally.",
      nativeTech = "Room / Preferences DataStore",
      nativeDesc = "Safe asynchronous local storage. Room provides full SQLite database engines while DataStore provides safe key-value buffers.",
      icon = Icons.Outlined.FolderZip
    )
  )
}
