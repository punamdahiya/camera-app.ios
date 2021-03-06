//
//  image_matcher.hpp
//  Lighthouse Camera
//
//  Created by Aleh Zasypkin on 19/12/2016.
//  Copyright © 2016 Lighthouse. All rights reserved.
//

#ifndef image_matcher_hpp
#define image_matcher_hpp

#include <stdio.h>
#include <string>
#include <unordered_map>
#include <opencv2/opencv.hpp>
#include <opencv2/features2d.hpp>

#include "image_description.hpp"

namespace lighthouse {

struct ImageMatchingSettings {
  int32_t mNumberOfFeatures, mMinNumberOfFeatures;
  float mRatioTestK, mHistogramWeight;
};

class ImageMatcher {
public:
  ImageMatcher(ImageMatchingSettings aSettings);

  ImageDescription GetDescription(const cv::Mat &aInputFrame) const;

  const ImageDescription &GetDescription(const std::string &id) const;

  std::vector<std::tuple<float, ImageDescription>> Match(const ImageDescription &aDescription) const;

  void AddToDB(const ImageDescription &aDescription);

private:
  cv::Ptr<cv::Feature2D> mKeypointDetector;
  cv::Ptr<cv::DescriptorMatcher> mMatcher;
  std::unordered_map<std::string, ImageDescription> mDB;
  ImageMatchingSettings mSettings;
};

} // namespace lighthouse

#endif /* image_matcher_hpp */
