import 'package:flutter/widgets.dart';

/// [duration], or zero when the platform asks for reduced motion.
Duration motionDuration(BuildContext context, Duration duration) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
